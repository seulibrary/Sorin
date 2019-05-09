defmodule Core.Dashboard.Collections do
  import Ecto.Query
  alias Core.{Collections, Repo, Notes, Files, Accounts}

  # NOTE: The functions in this module are all high-level
  #       and are intended only to be called in the context
  #       of an end-user doing something through an interface.
  #
  
  ###############################################
  # BASIC COLLECTION MECHANICS
  ##################

  @doc """
  Creates new collection and collections_users records.

  Takes a valid user_id as an integer and a collection title
  as a string.

  Computes and assigns the correct collections_users index value based
  on the indexes for the supplied user's current collections.

  Returns a custom map containing the new collection struct along
  with several fields from the associated collections_users struct.

  ## Examples

      iex> new_collection(user_id, title)
      [
       %{archived: false,
         cloned_from: nil,
         %Collection{},
         ...},
       ...
      ]

  """
  def new_collection(user_id, title) do
    index =
      Accounts.get_highest_collections_users_index(user_id) + 1
    user = Accounts.get_user!(user_id)
    
    Repo.transaction(fn ->
      {:ok, collection} =
	Collections.create_collection(
	  %{creator_id: user.id,
	    permalink: Ecto.UUID.generate(),	  
	    title: title,
	    write_users: [user.fullname]})
      {:ok, col_user} = 
	Collections.CollectionsUsers.changeset(
	  %Core.Collections.CollectionsUsers{},
	  %{user_id:       user.id,
	    collection_id: collection.id,
	    index: index,
	    write_access: true})
      |> Repo.insert
      
      from(
	c in Collections.Collection,
	left_join: cu in Collections.CollectionsUsers,
	on: c.id == cu.collection_id,
	where: cu.id == ^col_user.id,
	select: %{
	  archived:         cu.archived,
	  cloned_from:      cu.cloned_from,
	  collection:       c,
	  color:            cu.color,
	  index:            cu.index,
	  pending_approval: cu.pending_approval,
	  write_access:     cu.write_access})
      |> Repo.one
    end)
  end

  @doc """
  Updates a collection's title.

  Takes the collection id as an integer and the new title as a string.

  Returns a tagged tuple with either the edited collection struct or
  a changeset specifying the error.

  ## Examples

      iex> edit_collection_title(collection_id, string)
      {:ok, %Collection{}}

      iex> edit_collection_title([one or more bad values])
      {:error, #Ecto.Changeset}

  """
  def edit_collection_title(collection_id, string) do
    Core.Collections.get_collection!(collection_id)
    |> Core.Collections.update_collection(%{title: string})
  end
  
  @doc """
  Moves a collection from one position on a user's dashboard to
  another by assigning the collection the specified new index value
  and re-indexing other collections as appropriate.

  Takes a valid collection id as an integer, a valid user id as an
  integer, and a target index value (zero-indexed position) as an integer.

  Returns a tagged tuple with either the edited collection struct or
  a changeset specifying the error.

  ## Examples

      iex> move_collection(collection_id, user_id, target_index)
      {:ok, %Collection{}}

      iex> move_collection([one or more bad values])
      {:error, #Ecto.Changeset}

  """
  def move_collection(collection_id, user_id, target_index) do
    Repo.transaction(fn ->
      the_collection =
	Collections.CollectionsUsers
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)

      # Reindex collections_users above the source location down
      # There will temporarily be two collections with the same index
      from(cu in Collections.CollectionsUsers,
	where: cu.user_id == ^user_id
	and cu.index > ^the_collection.index)
      |> Repo.update_all(inc: [index: -1])
      
      # Reindex collections_users above the target index up
      from(cu in Collections.CollectionsUsers,
	where: cu.user_id == ^user_id
	and cu.index >= ^target_index)
      |> Repo.update_all(inc: [index: 1])

      # Set the_collection's index to target
      the_collection
      |> Ecto.Changeset.change(index: target_index)
      |> Repo.update!
    end)
  end

  ###############################################
  # REMOVE COLLECTIONS
  ####################

  @doc """
  High-level command for removing a specified collection from a specified
  user's dashboard (i.e., removing the collections_users record for the
  specified values).

  Takes a valid user id as an integer and a valid collection id as
  an integer.

  If the user is the creator of the collection, calls 
  remove_all_collections_users() for that collection id. Otherwise calls
  remove_one_collections_users().

  ## Examples

      iex> remove_collection(user_id, collection_id)
      :ok

  """
  def remove_collection(user_id, collection_id) do
    collection = Collections.get_collection!(collection_id)
    if user_id == collection.creator_id do
      remove_all_collections_users(collection)
    else
      remove_one_collections_users(user_id, collection_id)
    end
  end

  @doc """
  Removes the collections_users row for a specified user id and
  collection id.

  Takes valid collection_id and user_id as integers.

  If applicable, removes the user's fullname from the collection's
  write_users field.

  Reindexes remaining collections_users records as appropriate.

  ## Examples

      iex> remove_one_collections_users(user_id, collection_id)
      :ok

  """
  def remove_one_collections_users(user_id, collection_id) do
    collection_user =
      Collections.CollectionsUsers
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)

    if collection_user.write_access == true do
      Collections.remove_write_user(collection_id, user_id)
    end

    Repo.transaction(fn ->
      Repo.delete(collection_user)
      # Corrects the remaining collections_users rows indexes
      from(cu in Collections.CollectionsUsers,
	where: cu.user_id == ^user_id
	and cu.index > ^collection_user.index)
      |> Repo.update_all(inc: [index: -1])
    end)
  end

  @doc """
  Calls remove_one_collections_users() for each collections_users record
  for a given collection (which reindexes each user's remaining collections), 
  removes the collection, and calls Files.remove_orphaned_files().

  Takes a valid collection struct.

  ## Examples

      iex> remove_all_collections_users(%Collection{})
      :ok

  """
  def remove_all_collections_users(collection) do
    from(
      cu in Collections.CollectionsUsers,
      where: cu.collection_id == ^collection.id,
      select: cu.user_id
    )
    |> Repo.all() # Returns list of user_ids that have collection
    |> Enum.each(fn(x) ->
      remove_one_collections_users(x, collection.id)
    end)
    Repo.delete(collection)
    Files.remove_orphaned_files()
  end

  ############################################
  # PUBLISHING
  ############
  
  @doc """
  Sets a collection's "published" field to true. This could be done
  with Core.Collections.update_collection(); publish_collection() is
  supplied as a convenience for development in iex.

  Takes a valid collection id as an integer.

  Returns a tagged tuple with the updated collection struct or a changeset.

  ## Examples

      iex> publish_collection(collection_id)
      {:ok, %Collection{}}

      iex> publish_collection(bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def publish_collection(collection_id) do
    Core.Collections.get_collection!(collection_id)
    |> Core.Collections.update_collection(%{published: true})
  end

  ############################################
  # COLOR
  #######

  @doc """
  Updates the "color" field on the collections_users record for a specified
  user id, collection id, and color. This could be done with 
  Core.Collections.update_collection(); set_collection_color() is supplied 
  as a convenience for development in iex.

  Takes a valid collection id as an integer, a valid user id as an integer,
  and a valid hex color code as a string.

  Returns a tagged tuple with the updated collection struct or a changeset.

  ## Examples

      iex> set_collection_color(collection_id, user_id, "#FFFFFF")
      {:ok, %Collection{}}

      iex> set_collection_color([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def set_collection_color(collection_id, user_id, color) do
    Collections.CollectionsUsers
    |> Repo.get_by!(collection_id: collection_id, user_id: user_id)
    |> Ecto.Changeset.change(color: color)
    |> Repo.update
  end

  ###########################################
  # SHARING
  #########

  @doc """
  Creates a collections_users record for a specified collection id and
  user id, with the new record's collection_index value set correctly
  and its pending_approval set to true.

  Takes a valid collection id as an integer and a valid user id, to whom 
  the collection is being shared, as an integer.

  Will fail if the user already has that collection (i.e., if s/he has
  already cloned it).

  Returns an end-user-friendly string indicating the status of the request.

  ## Examples

      iex> share_collection(collection_id, user_id)
      "Collection shared and is now pending user's approval."

      iex> share_collection(collection_id, user_id_who_has_clone)
      "Error: User has cloned this collection and must remove the clone
      to become an author."

  """
  def share_collection(collection_id, target_user_id) do
    index =
      Accounts.get_highest_collections_users_index(target_user_id) + 1
    
    new_col_user =
      Collections.create_collections_users(
	%{collection_id: collection_id,
	  user_id: target_user_id,
	  index: index,
	  pending_approval: true})

    case new_col_user do
      {:ok, _}    -> "Collection shared and is now pending user's approval."
      _ -> "Error: User has cloned this collection and must remove the clone to become an author."
    end
  end

  @doc """
  High-level function for approving or rejecting a shared collection.

  Takes a valid collection id as an integer, a valid user id as an integer, 
  and a boolean for whether the collection is approved or not.

  If the share is approved, its collections_users pending_approval field is 
  set to false, its write_access field is set to true, and the user's 
  fullname is added to the list of write_users on the collection. 

  If the share is rejected, its collections_users record is removed.

  ## Examples

      iex> resolve_share(collection_id, user_id, true)
      {:ok, %Collection{}}

      iex> resolve_share(collection_id, user_id, false)
      %Collection{}

  """
  def resolve_share(collection_id, user_id, true) do
    Repo.transaction(fn ->
      Collections.CollectionsUsers
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)
      |> Ecto.Changeset.change(pending_approval: false, write_access: true)
      |> Repo.update

      Core.Collections.add_write_user(collection_id, user_id)
    end)
  end

  def resolve_share(collection_id, user_id, false) do
    Repo.transaction(fn ->
      Collections.CollectionsUsers
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)
      |> Repo.delete!()
    end)
  end

  ###############################################
  # NOTES
  #######

  @doc """
  Adds a note to a collection.

  Takes a valid collection id as an integer and a body as a string. 
  
  This could be done with the same values with Core.Notes.create_note(); 
  Core.Dashboard.Collections.add_note() and Core.Dashboard.Resources.add_note()
  are strictly redundant and should be refactored out.

  ## Examples

      iex> add_note(collection_id, string)
      {:ok, %Note{}}

      iex> add_note([one or more fields with bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_note(collection_id, string) do
    Notes.create_note(%{collection_id: collection_id, body: string})
  end

  ##########################################
  # TAGS
  ######

  @doc """
  Adds the specified string as a tag to the specified collection.

  Takes a tag as a string and a valid collection id as an integer.

  Returns a tagged tuple with either the updated collection or a
  changeset.

  ## Examples

      iex> add_tag_to_collection(string, collection_id)
      {:ok, %Collection{}}

      iex> add_tag_to_collection([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_tag_to_collection(string, collection_id) do
    collection =
      Collections.get_collection!(collection_id)

    list_of_tags =
      collection
      |> Map.get(:tags)
      |> List.insert_at(-1, String.upcase(string))

    collection
    |> Collections.update_collection(%{tags: list_of_tags})
  end

  @doc """
  Removes the specified string from the tags field of the specified
  collection.

  Takes a tag as a string and a valid collection id as an integer.

  Returns a tagged tuple with either the updated collection or a
  changeset.

  ## Examples

      iex> remove_tag_from_collection(string, collection_id)
      {:ok, %Collection{}}

      iex> remove_tag_from_collection([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def remove_tag_from_collection(string, collection_id) do
    collection =
      Collections.get_collection!(collection_id)

    list_of_tags =
      collection
      |> Map.get(:tags)
      |> List.delete(string)

    collection
    |> Collections.update_collection(%{tags: list_of_tags})
  end

  ######################
  # FILES
  #######

  @doc """
  High-level function for uploading a file to a collection.

  Takes a valid collection id as an integer, a file path, and a valid
  user id as an integer.

  Returns a tagged tuple with either the updated collection or a
  changeset.

  ## Examples

      iex> add_file(collection_id, "/home/rgibbs/a_file", user_id)
      {:ok, %File{}}

  """
  def add_file(collection_id, file_path, uploader_id) do
    Files.upload_file(file_path, uploader_id, :collection, collection_id)
  end

  @doc """
  High-level function for removing a file. Strictly redundant with
  Core.Files.delete_file_by_id(), which it calls with the same argument.

  Takes a valid file id as an integer.

  ## Examples

      iex> remove_file(file_id)
      {:ok, %{}}

  """
  def remove_file(file_id) do
    Files.delete_file_by_id(file_id)
  end

  #########################################
  # ARCHIVING
  ###########

  @doc """
  Sets the "archived" field in the collections_users record for a given
  collection id and user id to the value specified.

  Takes a valid collection id as an integer, a valid user id as an integer,
  and a boolean.

  Returns a tagged tuple with either the updated collection_users struct
  or a changeset.

  ## Examples

      iex> archive_collection(collection_id, user_id, true)
      {:ok, %CollectionsUsers{}}

      iex> archive_collection([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def archive_collection(collection_id, user_id, true_or_false) do
    Collections.CollectionsUsers
    |> Repo.get_by!(collection_id: collection_id, user_id: user_id)
    |> Ecto.Changeset.change(archived: true_or_false)
    |> Repo.update
  end

  ####################################
  # GET CLONERS
  #############

  @doc """
  Gets a list of structs for all users who currently have the specified
  collection_id cloned.

  Takes a valid collection id as an integer.

  Returns a list of user structs.

  ## Examples

      iex> get_cloners(collection_that_has_clones)
      [
       %User{},
       %User{},
       ...
      ]

      iex> get_cloners(collection_with_no_clones)
      []

  """
  def get_cloners(collection_id) do
    from(
      c in Collections.Collection,
      left_join: cu in Collections.CollectionsUsers,
      on: c.id == cu.collection_id,
      left_join: u in Accounts.User,
      on: cu.user_id == u.id,
      where: c.id == ^collection_id,
      where: cu.write_access == false,
      select: u)
      |> Repo.all()
  end
  
end

