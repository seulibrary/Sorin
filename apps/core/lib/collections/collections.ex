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
      from(r in Core.Resources.Resource,
	where: r.collection_id == ^collection_id,
	select: r.collection_index,
	order_by: r.collection_index
      )
      |> Core.Repo.all()
      |> Enum.at(-1)

    case index do
      nil -> -1
      _ -> index
    end
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
