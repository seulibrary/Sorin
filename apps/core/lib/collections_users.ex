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
