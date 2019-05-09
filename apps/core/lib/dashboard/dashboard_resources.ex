defmodule Core.Dashboard.Resources do
  import Ecto.Query
  alias Core.{Collections, Resources, Repo, Notes, Files}

  # NOTE: The functions in this module are all high-level
  #       and are intended only to be called in the context
  #       of an end-user doing something through an interface.
  #

  ############################################
  # BASIC RESOURCE MECHANICS
  ################

  @doc """
  High-level function for creating an indexed resource. Calculates and adds
  the correct collection_index value for the specified collection.

  Takes a map of values, and a valid collection id as an integer.

  Returns a tagged tuple with either the new resource struct or
  a changeset.

  ## Examples

      iex> create_indexed_resource(collection_id, %{})
      {:ok, %Resource{}}

      iex> create_indexed_resource([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def create_indexed_resource(data, collection_id) do
    index =
      Collections.get_highest_resources_index(collection_id) + 1

    data
    |> Map.put("collection_id", collection_id)
    |> Map.put("collection_index", index)
    |> Resources.create_resource()
  end

  @doc """
  High-level function for moving a resource from one place in a specified
  user's dashboard to another, reindexing the source and target collections.

  Takes a valid resource id as an integer, a valid collection id as an
  integer, and a target index (i.e., zero-indexed position in the target
  collection).

  ## Examples

      iex> move_resource(resource_id, target_collection_id, target_index)
      {:ok, {:ok, %Resource{}}}

  """
  def move_resource(
    resource_id,
    target_collection_id,
    target_index) do

    resource =
      Resources.get_resource!(resource_id)

    Repo.transaction(fn ->
      # Reindex source collection's resources
      from(r in Resources.Resource,
	where: r.collection_id == ^resource.collection_id
	and r.collection_index > ^resource.collection_index)
      |> Repo.update_all(inc: [collection_index: -1])

      # Reindex target collection's resources
      from(r in Resources.Resource,
	where: r.collection_id == ^target_collection_id
	and r.collection_index >= ^target_index)
      |> Repo.update_all(inc: [collection_index: 1])

      # Move resource
      resource
      |> Resources.update_resource(
	%{collection_id: target_collection_id,
	  collection_index: target_index})
    end)
  end

  @doc """
  High-level function for removing a resource; reindexes the collection it
  was in and correctly removes any file attachments.

  Takes a valid resource id as an integer.

  ## Examples

      iex> remove_resource(resource_id)
      :ok

  """
  def remove_resource(resource_id) do
    resource =
      Resources.get_resource!(resource_id)
    
    Repo.transaction(fn ->
      resource
      |> Resources.delete_resource()

      # Reindex remaining resources
      from(r in Resources.Resource,
	where: r.collection_id == ^resource.collection_id
	and r.collection_index > ^resource.collection_index)
      |> Repo.update_all(inc: [collection_index: -1])
    end)
    Files.remove_orphaned_files()
  end

  ############################################
  # NOTES
  #######

  @doc """
  Adds a note to a resource.

  Takes a valid resource id as an integer and a body as a string. 
  
  This could be done with the same values with Core.Notes.create_note(); 
  Core.Dashboard.Collections.add_note() and Core.Dashboard.Resources.add_note()
  are strictly redundant and should be refactored out.

  ## Examples

      iex> add_note(resource_id, string)
      {:ok, %Note{}}

      iex> add_note([one or more fields with bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_note(resource_id, string) do
    Notes.create_note(%{resource_id: resource_id, body: string})
  end

  ##########################################
  # TAGS
  ######

  @doc """
  Adds the specified string as a tag to the specified resource.

  Takes a tag as a string and a valid resource id as an integer.

  Returns a tagged tuple with either the updated resource or a
  changeset.

  ## Examples

      iex> add_tag_to_resource(string, resource_id)
      {:ok, %Resource{}}

      iex> add_tag_to_resource([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_tag_to_resource(resource_id, string) do
    resource =
      Resources.get_resource!(resource_id)

    list_of_tags =
      resource
      |> Map.get(:tags)
      |> List.insert_at(-1, String.upcase(string))

    resource
    |> Resources.update_resource(%{tags: list_of_tags})
  end

  @doc """
  Removes the specified string from the tags field of the specified
  resource.

  Takes a tag as a string and a valid resource id as an integer.

  Returns a tagged tuple with either the updated resource or a
  changeset.

  ## Examples

      iex> remove_tag_from_resource(string, resource_id)
      {:ok, %Resource{}}

      iex> remove_tag_from_resource([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def remove_tag_from_resource(resource_id, string) do
    resource =
      Resources.get_resource!(resource_id)

    list_of_tags =
      resource
      |> Map.get(:tags)
      |> List.delete(string)

    resource
    |> Resources.update_resource(%{tags: list_of_tags})
  end

  ######################
  # FILES
  #######

  @doc """
  High-level function for uploading a file to a resource.

  Takes a valid resource id as an integer, a file path, and a valid
  user id as an integer.

  Returns a tagged tuple with either the updated resource or a
  changeset.

  ## Examples

      iex> add_file(resource_id, "/home/rgibbs/a_file", user_id)
      {:ok, %File{}}

  """
  def add_file(resource_id, file_path, uploader_id) do
    Files.upload_file(file_path, uploader_id, :resource, resource_id)
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
  
end
