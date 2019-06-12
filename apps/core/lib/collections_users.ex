defmodule Core.CollectionsUsers do
  @moduledoc """
  The CollectionsUsers context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.{
    Collections,
    CollectionsUsers.CollectionUser,
    Files
  }

  @doc """
  Moves a collection from one position on a user's dashboard to
  another by assigning a specified new index value to its
  CollectionsUsers record and re-indexing the user's other collections
  as appropriate.

  Takes a valid collection id as an integer, a valid user id as an
  integer, and a target index value (zero-indexed position) as an integer.

  Returns either the updated CollectionsUsers struct or a changeset
  specifying the error.

  ## Examples

      iex> move_collection(collection_id, user_id, target_index)
      %Core.CollectionsUsers.CollectionUser{}

      iex> move_collection([one or more bad values])
      {:error, #Ecto.Changeset}

  """
  def move_collection(collection_id, user_id, target_index) when target_index > 0 do
    col_user =
      CollectionUser
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)

    # Reindex collections_users above the source location down
    # There will temporarily be two collections with the same index
    from(cu in CollectionUser,
      where:
        cu.user_id == ^user_id and
          cu.index > ^col_user.index
    )
    |> Repo.update_all(inc: [index: -1])

    # Reindex collections_users above the target index up
    from(cu in CollectionUser,
      where:
        cu.user_id == ^user_id and
          cu.index >= ^target_index
    )
    |> Repo.update_all(inc: [index: 1])

    # Set the_collection's index to target
    col_user
    |> Ecto.Changeset.change(index: target_index)
    |> Repo.update!()
  end

  def move_collection(_, _, target_index) when target_index <= 0 do
    {:error, "User collections cannot be moved into the first position."}
  end

  @doc """
  High-level function for removing a given collection from a given user's
  collections and re-indexing their remaining collections.

  Removes the collections_users row for a specified user id and collection id.

  Takes valid collection_id and user_id as integers.

  Either removes the user's fullname from the collection's write_users field
  or decrements the collection's clones_count.

  Reindexes remaining collections_users records as appropriate.

  ## Examples

      iex> remove_one_col_user(collection_id, user_id)
      :ok

  """
  def remove_one_col_user(collection_id, user_id) do
    collection_user =
      CollectionUser
      |> Repo.get_by!(collection_id: collection_id, user_id: user_id)

    case collection_user.write_access do
      true ->
        Collections.remove_write_user(collection_id, user_id)

      false ->
        from(c in Collections.Collection,
          where: c.id == ^collection_id
        )
        |> Core.Repo.update_all(inc: [clones_count: -1])
    end

    Repo.transaction(fn ->
      Repo.delete(collection_user)
      # Corrects the remaining collections_users indexes
      from(cu in CollectionUser,
        where:
          cu.user_id == ^user_id and
            cu.index > ^collection_user.index
      )
      |> Repo.update_all(inc: [index: -1])
    end)
  end

  @doc """
  Returns the list of collections_users.

  ## Examples

      iex> list_collections_users()
      [%CollectionUser{}, ...]

  """
  def list_collections_users do
    Repo.all(CollectionUser)
  end

  @doc """
  Gets a single collection_user.

  Raises `Ecto.NoResultsError` if the Collection user does not exist.

  ## Examples

      iex> get_collection_user!(123)
      %CollectionUser{}

      iex> get_collection_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection_user!(id), do: Repo.get!(CollectionUser, id)

  @doc """
  Creates a collection_user.

  ## Examples

      iex> create_collection_user(%{field: value})
      {:ok, %CollectionUser{}}

      iex> create_collection_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection_user(attrs \\ %{}) do
    %CollectionUser{}
    |> CollectionUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection_user.

  ## Examples

      iex> update_collection_user(collection_user, %{field: new_value})
      {:ok, %CollectionUser{}}

      iex> update_collection_user(collection_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection_user(%CollectionUser{} = collection_user, attrs) do
    collection_user
    |> CollectionUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CollectionUser.

  ## Examples

      iex> delete_collection_user(collection_user)
      {:ok, %CollectionUser{}}

      iex> delete_collection_user(collection_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection_user(%CollectionUser{} = collection_user) do
    Repo.delete(collection_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection_user changes.

  ## Examples

      iex> change_collection_user(collection_user)
      %Ecto.Changeset{source: %CollectionUser{}}

  """
  def change_collection_user(%CollectionUser{} = collection_user) do
    CollectionUser.changeset(collection_user, %{})
  end
end
