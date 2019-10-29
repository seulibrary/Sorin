defmodule ApiWeb.Utils do
  @moduledoc """
  Utility functions
  To be used in ApiWeb
  """

  @doc """
  Returns true if list is empty.

  ## Examples

      iex> nil?([])
      true
  """
  def nil?([]), do: true

  @doc """
  Returns false if list is not empty.

  ## Examples

      iex> nil?([1, 2])
      false
  """
  def nil?(list) when is_list(list) do
    false
  end

  @doc """
  Returns true if string is empty.

  ## Examples

      iex> nil?("")
      true
  """
  def nil?(string) when string == "" do
    true
  end

  @doc """
  Returns true if string is nil.

  ## Examples

      iex> nil?(nil)
      true
  """
  def nil?(string) when string == nil do
    true
  end

  @doc """
  Returns false if string is not empty.

  ## Examples

      iex> nil?("Hello")
      false
  """
  def nil?(_string) do
    false
  end

  @doc """
  returns sanitized map
  It removes non-loaded associated references. 
  """
  def sanitize_for_poison(collection) do
    map = collection
      |> Map.from_struct()
      |> Map.drop([:__meta__, :__struct__, :__cardinality__, :__field__,  :__owner__])

    :maps.filter(fn _, value -> Ecto.assoc_loaded?(value) end, map)
  end

  @doc """
  Checks to see is a collection is the given users inbox.

  ## Examples

        iex> is_inbox(1, 1)
        (true || false)
  """
  def is_inbox(user_id, collection_id) do
    index = Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by!(
      collection_id: collection_id,
      user_id: user_id
    )
    |> Map.get(:index)

    case index do
      0 -> true
      _ -> false
    end
  end

  @doc """
  Checks to see if a collection can be edited by the user.

  Returns a CollectionUser
  """
  def can_edit_collection(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by(
      collection_id: collection_id,
      user_id: user_id,
      write_access: true)
    |> Core.Repo.preload(:collection) do
      user when is_nil(user) -> {:error, "User does not have permission"}
      collection -> {:ok, collection}
    end
  end

  @doc """
  Checks to see if a collection can be edited by the user.

  Returns true or false
  """
  def can_edit_collection?(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by(
      collection_id: collection_id,
    user_id: user_id,
    write_access: true
    ) do
      _user when is_nil(_user) -> false
      collection -> true
    end
  end

  @doc """
  Checks to see if a user can change the index of a CollectionUser.
  
  Returns a CollectionUser
  """
  def can_move_collection(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by!(
      collection_id: collection_id,
      user_id: user_id)
    |> Core.Repo.preload(:collection) do
      _users when is_nil(_users) -> {:error, "User does not have permission"}
      collectionUser -> {:ok, collectionUser}
    end
  end

  @doc """
  Checks to see if a user can change the index of a CollectionUser.
  
  Returns a true or false
  """
  def can_move_collection?(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by!(
      collection_id: collection_id, 
      user_id: user_id
    ) do
      _users when is_nil(_users) -> false
      _ -> true
    end
  end
end
