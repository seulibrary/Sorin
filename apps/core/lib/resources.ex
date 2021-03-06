defmodule Core.Resources do
  @moduledoc """
  The Resources context.
  """
  import Ecto.Query, warn: false
  alias Core.{
    Collections,
    Files,
    Repo,
    Resources.Resource,
  }

  @doc """
  High-level function for copying a resource and its associated note
  from one collection to another. Preserves the collection_index of
  the original resource; thus, only called by import_collection(), which
  calls it successively on every resource in the source collection.

  Takes a valid resource id as an integer and a valid collection id as an
  integer.

  Returns the new resource struct.

  ## Examples

      iex> copy_resource(resource_id, collection_id)
      %Resource{}

  """
  def copy_resource(resource_id, target_collection_id) do
    source_resource =
      get_resource!(resource_id)
      |> Repo.preload(:notes)

    {:ok, new_resource} =
      source_resource
      |> Map.from_struct()
      |> Map.delete(:id)
      |> Map.put(:collection_id, target_collection_id)
      |> create_resource()

    # If a note exists, migrate the association
    cond do
      source_resource.notes == nil ->
        nil

      true ->
        Core.Notes.import_note_by_id(
          source_resource.notes.id,
          :resource,
          new_resource.id
        )
    end

    new_resource
  end

  @doc """
  High-level function for copying a resource and its associated note
  from one collection to another. Requires the specification of a target
  collection index; thus, intended to be used by end users for copying
  a resource from one of their collections to another. Does not copy
  file attachments.

  Takes a valid resource id as an integer, a valid collection id as an
  integer, and a target index as an integer (i.e., a zero-indexed position
  in the target collection).

  Returns the new resource struct.

  ## Examples

      iex> copy_resource(resource_id, collection_id, target_index)
      %Resource{}

  """
  def copy_resource(resource_id, target_collection_id, target_index) do
    source_resource =
      get_resource!(resource_id)
      |> Repo.preload(:notes)

    # Reindex target collection's resources
    from(r in Resource,
      where:
        r.collection_id == ^target_collection_id and
          r.collection_index >= ^target_index
    )
    |> Repo.update_all(inc: [collection_index: 1])

    {:ok, new_resource} =
      source_resource
      |> Map.from_struct()
      |> Map.delete(:id)
      |> Map.put(:collection_index, target_index)
      |> Map.put(:collection_id, target_collection_id)
      |> create_resource()

    # If a note exists, migrate the association
    cond do
      source_resource.notes == nil ->
        nil

      true ->
        Core.Notes.import_note_by_id(
          source_resource.notes.id,
          :resource,
          new_resource.id
        )
    end

    # Return the new resource
    new_resource
  end

  @doc """
  High-level function for creating an indexed resource. Calculates and adds
  the correct collection_index value for the specified collection.

  Takes a map of values, and a valid collection id as an integer.

  Returns a tagged tuple with either the new resource struct or
  a changeset.

  ## Examples

      iex> create_indexed_resource(%{}, collection_id)
      {:ok, %Resource{}}

      iex> create_indexed_resource([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def create_indexed_resource(resource_map, collection_id) do
    index =
      Collections.get_highest_resources_index(collection_id) + 1

    resource_map
    |> Map.put("collection_id", collection_id)
    |> Map.put("collection_index", index)
    |> create_resource()
  end

  @doc """
  High-level function for moving a resource from one place in a specified
  user's dashboard to another, reindexing the source and target collections.

  Takes a valid resource id as an integer, a valid collection id as an
  integer, and a target index (i.e., zero-indexed position in the target
  collection).

  ## Examples

      iex> move_resource_by_id(resource_id, target_collection_id, target_index)
      %Resource{}

  """
  def move_resource_by_id(
    resource_id,
    target_collection_id,
    target_index) do

    resource = get_resource!(resource_id)

    Repo.transaction(fn ->
      # Reindex source collection's resources
      from(r in Resource,
	where: r.collection_id == ^resource.collection_id
	and r.collection_index > ^resource.collection_index)
      |> Repo.update_all(inc: [collection_index: -1])

      # Reindex target collection's resources
      from(r in Resource,
	where: r.collection_id == ^target_collection_id
	and r.collection_index >= ^target_index)
      |> Repo.update_all(inc: [collection_index: 1])

      # Move resource
      resource
      |> update_resource(
	%{collection_id: target_collection_id,
	  collection_index: target_index})
    end)

    get_resource!(resource_id)
  end

  @doc """
  High-level function for removing a resource; reindexes the collection it
  was in and correctly removes any file attachments.

  Takes a valid resource id as an integer.

  ## Examples

      iex> remove_resource_by_id(resource_id)
      :ok

  """
  def remove_resource_by_id(resource_id) do
    resource = get_resource!(resource_id)

    Repo.transaction(fn ->
      resource
      |> delete_resource()

      # Reindex remaining resources
      from(r in Resource,
	where: r.collection_id == ^resource.collection_id
	and r.collection_index > ^resource.collection_index)
      |> Repo.update_all(inc: [collection_index: -1])
    end)

    Files.remove_orphaned_files()

    :ok
  end

  @doc """
  Adds the specified string as a tag to the specified resource.

  Takes a tag as a string and a valid resource id as an integer.

  Returns a tagged tuple with either the updated resource or a
  changeset.

  ## Examples

      iex> add_tag_by_resource_id(string, resource_id)
      {:ok, %Resource{}}

      iex> add_tag_by_resource_id([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def add_tag_by_resource_id(resource_id, string) do
    resource = get_resource!(resource_id)

    list_of_tags =
      resource
      |> Map.get(:tags)
      |> List.insert_at(-1, String.upcase(string))

    resource
    |> update_resource(%{tags: list_of_tags})
  end

  @doc """
  Removes the specified string from the tags field of the specified
  resource.

  Takes a tag as a string and a valid resource id as an integer.

  Returns a tagged tuple with either the updated resource or a
  changeset.

  ## Examples

      iex> remove_tag_by_resource_id(string, resource_id)
      {:ok, %Resource{}}

      iex> remove_tag_by_resource_id([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def remove_tag_by_resource_id(resource_id, string) do
    resource = get_resource!(resource_id)

    list_of_tags =
      resource
      |> Map.get(:tags)
      |> List.delete(string)

    resource
    |> update_resource(%{tags: list_of_tags})
  end

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resource{}, ...]

  """
  def list_resources do
    Repo.all(Resource)
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id), do: Repo.get!(Resource, id)

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{source: %Resource{}}

  """
  def change_resource(%Resource{} = resource) do
    Resource.changeset(resource, %{})
  end
end
