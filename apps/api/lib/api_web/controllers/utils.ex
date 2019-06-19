defmodule ApiWeb.Utils do
  def nil?([]), do: true

  def nil?(list) when is_list(list) do
    false
  end

  def nil?(string) when string == "" do
    true
  end

  def nil?(string) when string == nil do
    true
  end

  def nil?(_string) do
    false
  end

  def sanitize_for_poison(collection) do
    map = collection
      |> Map.from_struct()
      |> Map.drop([:__meta__, :__struct__, :__cardinality__, :__field__,  :__owner__])

    :maps.filter(fn _, value -> Ecto.assoc_loaded?(value) end, map)
  end

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

  def can_edit_collection(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by(
      collection_id: collection_id,
      user_id: user_id,
      write_access: true
    ) do
      _user when is_nil(_user) -> {:error, "User does not have permission"}
      _ -> {:ok, "User can edit collection."}
    end
  end

  def can_move_collection(user_id, collection_id) do
    case Core.CollectionsUsers.CollectionUser
    |> Core.Repo.get_by!(
      collection_id: collection_id,
      user_id: user_id
    ) do
      _users when is_nil(_users) -> {:error, "User does not have permission"}
      _ -> {:ok, "User can move collection."}
    end
  end

  def can_move_collection!(user_id, collection_id) do
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
