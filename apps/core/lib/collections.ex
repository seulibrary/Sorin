defmodule Core.Collections do
  @moduledoc """
  The Collections context.
  """
  import Ecto.Query, warn: false
  alias Core.{
    Accounts,
    Collections.Collection,
    CollectionsUsers,
    Notes,
    Repo,
    Resources,
    Resources.Resource,
  }

  @doc """
  High-level function for creating a collection. Creates a new
  collection with the specified title and creates a CollectionsUsers
  record for it, joining it with the user account specified by the
  supplied user_id.

  Takes a valid user_id as an integer and a collection title
  as a string.

  Computes and assigns the correct collections_users index value based
  on the supplied user's existing collections.

  Returns the new CollectionsUsers struct with the new Collection
  struct preloaded.

  ## Examples

      iex> new_collection(user_id, title)
      %Core.CollectionsUsers.CollectionUser{}

  """
  def new_collection(user_id, title) do
    index = Accounts.get_highest_col_user_index(user_id) + 1
    user = Accounts.get_user!(user_id)

    date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()

    with {:ok, collection} <-
           create_collection(%{
             chain_of_cust: ["Created by #{user.fullname} on #{date}"],
             creator_id: user.id,
             permalink: Ecto.UUID.generate(),
             title: title,
             write_users: [user.fullname]
           }),
         {:ok, col_user} <-
           CollectionsUsers.create_collection_user(%{
             user_id: user.id,
             collection_id: collection.id,
             index: index,
             write_access: true
           }) do
      CollectionsUsers.get_collection_user!(col_user.id)
      |> Repo.preload(:collection)
    end
  end

  @doc """
  Gets a specific set of fields intended for the
  permalink view of a collection.

  Takes the collection's uuid as a string.

  ## Examples

      iex> get_permalink_view(string)
      [%Collection{}, ...]

  """
  def get_permalink_view(uuid) do
    resources_query =
      from(
        r in Resource,
        preload: [:notes],
        order_by: r.collection_index
      )

    from(
      c in Collection,
      where: c.permalink == ^uuid,
      select: c,
      preload: [:notes, resources: ^resources_query]
    )
    |> Repo.all()
  end

  @doc """
  Adds the fullname of the specified user to the write_users field of a
  collection, and appends to its chain_of_custody a string recording
  that the new user was granted write access on [timestamp].

  Takes valid collection_id and user_id as integers.

  Returns the updated collection.

  ## Examples

      iex> add_write_user(collection_id, user_id)
      {:ok, %Core.Collections.Collection{}}

  """
  def add_write_user(collection_id, user_id) do
    collection = get_collection!(collection_id)

    new_writer_fullname =
      Accounts.get_user!(user_id)
      |> Map.get(:fullname)

    new_list_of_authors =
      collection
      |> Map.get(:write_users)
      |> List.insert_at(-1, new_writer_fullname)

    date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()

    new_chain_of_cust =
      collection
      |> Map.get(:chain_of_cust)
      |> List.insert_at(
        -1,
        "#{new_writer_fullname} granted write access on #{date}"
      )

    collection
    |> update_collection(%{chain_of_cust: new_chain_of_cust, write_users: new_list_of_authors})
  end

  @doc """
  Removes the fullname of the specified user from the write_users field of a
  collection, and appends to its chain_of_custody a string recording that
  the new user's write access was revoked on [timestamp].

  Takes valid collection_id and user_id as integers.

  Returns the updated collection.

  ## Examples

      iex> remove_write_user(collection_id, user_id)
      {:ok, %Core.Collections.Collection{}}

  """
  def remove_write_user(collection_id, user_id) do
    collection = get_collection!(collection_id)

    writer_fullname =
      Accounts.get_user!(user_id)
      |> Map.get(:fullname)

    new_list_of_authors =
      collection
      |> Map.get(:write_users)
      |> List.delete(writer_fullname)

    date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()

    new_chain_of_cust =
      collection
      |> Map.get(:chain_of_cust)
      |> List.insert_at(-1, "Write access withdrawn from #{writer_fullname} on #{date}")

    collection
    |> update_collection(%{chain_of_cust: new_chain_of_cust, write_users: new_list_of_authors})
  end

  @doc """
  Returns the collection_index value of the resource with the highest
  collection_index value for a given collection. Used by functions that
  automatically append resources to a collection, which therefore
  have to calculate and assign a higher collection_index value.

  Takes a valid collection id as an integer.

  Returns the collection_index as an integer.

  ## Example

      iex> get_highest_resources_index(3)
      4

  """
  def get_highest_resources_index(collection_id) do
    index =
      from(
        r in Resource,
        where: r.collection_id == ^collection_id,
        select: r.collection_index,
        order_by: r.collection_index
      )
      |> Repo.all()
      |> Enum.at(-1)

    case index do
      nil -> -1
      _ -> index
    end
  end

  @doc """
  High-level command for removing a specified collection from a specified
  user's account and, if the user is the creator of the collection, deleting
  it out of the universe.

  Takes a valid user id as an integer and a valid collection id as
  an integer.

  If the user is the creator of the collection, calls
  Core.CollectionsUsers.remove_all_col_users() for that collection id.
  Otherwise calls Core.CollectionsUsers.remove_one_col_user().

  ## Examples

      iex> remove_collection(collection_id, user_id)
      :ok

  """
  def remove_collection(collection_id, user_id) do
    collection = get_collection!(collection_id)

    if user_id == collection.creator_id do
      CollectionsUsers.remove_all_col_users(collection)
    else
      CollectionsUsers.remove_one_col_user(collection_id, user_id)
    end
  end

  @doc """
  Adds the specified string as a tag to the specified collection.

  Takes a valid collection id as an integer and the new tag as a
  string.

  Returns a tagged tuple with either the updated collection or a
  changeset.

  ## Examples

      iex> add_tag_by_collection_id(collection_id, string)
      {:ok, %Collection{}}

      iex> add_tag_by_collection_id([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_tag_by_collection_id(collection_id, string) do
    collection = get_collection!(collection_id)

    list_of_tags =
      collection
      |> Map.get(:tags)
      |> List.insert_at(-1, String.upcase(string))

    collection
    |> update_collection(%{tags: list_of_tags})
  end

  @doc """
  Removes the specified string from the tags field of the specified
  collection.

  Takes a tag as a string and a valid collection id as an integer.

  Returns a tagged tuple with either the updated collection or a
  changeset.

  ## Examples

      iex> remove_tag_by_collection_id(collection_id, string)
      {:ok, %Collection{}}

      iex> remove_tag_by_collection_id([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def remove_tag_by_collection_id(collection_id, string) do
    collection = get_collection!(collection_id)

    list_of_tags =
      collection
      |> Map.get(:tags)
      |> List.delete(string)

    collection
    |> update_collection(%{tags: list_of_tags})
  end

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
    index = Accounts.get_highest_col_user_index(target_user_id) + 1

    new_col_user =
      CollectionsUsers.create_collection_user(%{
        collection_id: collection_id,
        user_id: target_user_id,
        index: index,
        pending_approval: true
      })

    case new_col_user do
      {:ok, collectionUser} ->
        {:ok, collectionUser |> Repo.preload(:collection)}

      _ ->
        {:error, "Error: User has cloned this collection and must remove the clone to " <>
        "become an author." }
    end
  end

  @doc """
  High-level function for "cloning" a collection, where cloning means that
  a new collections_users record is created for the specified collection and
  user, with write_access set to false. The collection will appear on the new
  user's dashboard, and they will get all updates to it, but they will not be
  able to edit it themselves.

  The original collection's "clones_count" field is incremented, and the
  "cloned_from" field on the new collections_users record is populated with
  the fullname of the original collection's creator.

  Takes a valid collection id as an integer and a valid user id as an integer.

  Returns the new CollectionUser struct with all content preloaded.

  ## Example

      iex> clone_collection_by_id(collection_id, user_id)
      %Core.CollectionsUsers.CollectionUser{}

  """
  def clone_collection_by_id(collection_id, user_id) do
    new_index = Accounts.get_highest_col_user_index(user_id) + 1

    # Get the creator's fullname to write it into the clone
    creator_name =
      from(c in Collection,
        left_join: u in Accounts.User,
        on: c.creator_id == u.id,
        where: c.id == ^collection_id,
        select: u.fullname
      )
      |> Repo.one()

    # Create the CollectionUser record
    {:ok, clone} =
      CollectionsUsers.create_collection_user(%{
        collection_id: collection_id,
        user_id: user_id,
        index: new_index,
        write_access: false,
        cloned_from: creator_name
      })

    # Increment the collection's clones_count
    from(c in Collection,
      where: c.id == ^collection_id
    )
    |> Core.Repo.update_all(inc: [clones_count: 1])

    # Return the clone with associations preloaded
    resources_query =
      from r in Resource,
        preload: [:files, :notes],
        order_by: r.collection_index

    from(cu in CollectionsUsers.CollectionUser,
      where: cu.user_id == ^user_id,
      where: cu.id == ^clone.id,
      preload: [collection: [:files, :notes, resources: ^resources_query]]
    )
    |> Repo.one()
  end

  @doc """
  High-level function for "importing" a collection, where importing means
  the specified collection is exactly recreated as an original collection
  for the specified user with all content and associations intact, except
  files, which are not imported.

  The original collection's "imports_count" field is incremented, the new
  collection's "import_stamp" is populated with a string recording that it was
  imported from [fullname of original collection's creator] on [timestamp], and
  the new collection's "chain_of_cust" field is first copied from the source,
  then appended to with a string recording that it was imported by [fullname
  of the importer] on [timestamp].

  Takes a valid collection id as an integer and a valid user id as an integer.

  Returns the new CollectionsUsers struct with all associations preloaded and
  ordered.

  ## Example

      iex> import_collection(collection_id, user_id)
      %Core.CollectionsUsers.CollectionUser{}

  """
  def import_collection_by_id(collection_id, user_id) do
    new_index = Accounts.get_highest_col_user_index(user_id) + 1

    # Source collection query, with all associations preloaded and ordered
    resources_query =
      from r in Resource,
        preload: [:notes],
        order_by: r.collection_index

    source_collection =
      from(c in Collection,
        where: c.id == ^collection_id,
        select: c,
        preload: [:notes, resources: ^resources_query]
      )
      |> Repo.one()

    # Get current timestamp and full name of the source collection's creator
    # for the new collection's import_stamp field
    date =
      DateTime.utc_now()
      |> DateTime.truncate(:second)
      |> DateTime.to_naive()

    creator_fullname =
      Accounts.get_user!(source_collection.creator_id)
      |> Map.get(:fullname)

    # Get fullname of new user for write_users and chain of custody for new
    # collection
    new_user_fullname =
      Accounts.get_user!(user_id)
      |> Map.get(:fullname)

    # Get chain of custody of source collection to append new owner to
    new_chain_of_cust =
      source_collection
      |> Map.get(:chain_of_cust)
      |> List.insert_at(-1, "Imported by #{new_user_fullname} on #{date}")

    # Create the new collection
    {:ok, new_collection} =
      create_collection(%{
        chain_of_cust: new_chain_of_cust,
        creator_id: user_id,
        import_stamp: "Imported from #{creator_fullname} on #{date} UTC",
        permalink: Ecto.UUID.generate(),
        title: source_collection.title,
        write_users: [new_user_fullname]
      })

    # Create the new collections_users record
    Repo.transaction(fn ->
      CollectionsUsers.create_collection_user(%{
        collection_id: new_collection.id,
        user_id: new_collection.creator_id,
        index: new_index,
        write_access: true
      })

      # Increment imports count on original
      from(c in Collection,
        where: c.id == ^collection_id
      )
      |> Repo.update_all(inc: [imports_count: 1])
    end)

    # If exists, migrate note association
    cond do
      source_collection.notes == nil ->
        nil

      true ->
        Notes.import_note_by_id(
          source_collection.notes.id,
          :collection,
          new_collection.id
        )
    end

    # Import resources to the new collection. First gets list of resource
    # IDs, then for each, calls copy_resource.
    #
    # NOTE: Core.Resources.copy_resource() creates a new resource with
    #       certain fields copied from the original. Notes are imported,
    #       but not files.
    source_collection.resources
    |> Enum.map(fn resource -> Map.get(resource, :id) end)
    |> Enum.map(fn id -> Resources.copy_resource(id, new_collection.id) end)

    # Return the imported collection with associations preloaded
    from(cu in CollectionsUsers.CollectionUser,
      where: cu.user_id == ^user_id,
      where: cu.collection_id == ^new_collection.id,
      preload: [collection: [:files, :notes, resources: ^resources_query]]
    )
    |> Repo.one()
  end

  @doc """
  Returns the list of collections.

  ## Examples

      iex> list_collections()
      [%Collection{}, ...]

  """
  def list_collections do
    Repo.all(Collection)
  end

  @doc """
  Gets a single collection.

  Raises `Ecto.NoResultsError` if the Collection does not exist.

  ## Examples

      iex> get_collection!(123)
      %Collection{}

      iex> get_collection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection!(id), do: Repo.get!(Collection, id)

  @doc """
  Creates a collection.

  ## Examples

      iex> create_collection(%{field: value})
      {:ok, %Collection{}}

      iex> create_collection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection.

  ## Examples

      iex> update_collection(collection, %{field: new_value})
      {:ok, %Collection{}}

      iex> update_collection(collection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Collection.

  ## Examples

      iex> delete_collection(collection)
      {:ok, %Collection{}}

      iex> delete_collection(collection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection changes.

  ## Examples

      iex> change_collection(collection)
      %Ecto.Changeset{source: %Collection{}}

  """
  def change_collection(%Collection{} = collection) do
    Collection.changeset(collection, %{})
  end
end
