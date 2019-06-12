defmodule Core.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Core.{
    Accounts.User,
    Collections,
    Collections.Collection,
    CollectionsUsers,
    CollectionsUsers.CollectionUser,
    Files,
    Repo,
    Resources.Resource,
  }

  @doc """
  Gets all CollectionsUsers records for a specified user, ordered by
  index and with all associations preloaded and ordered by index.

  Takes a valid user_id as an integer.

  Returns an ordered list of CollectionsUsers structs with associated
  structs.

  ## Examples

      iex> get_dashboard(user_id)
      [%Core.CollectionsUsers.CollectionUser{}, ...]

  """
  def get_dashboard(user_id) do
    resources_query =
      from r in Resource,
      preload: [:files, :notes],
      order_by: r.collection_index

    from(
      cu in CollectionUser,
      where: cu.user_id == ^user_id,
      preload: [
    	collection: [
    	  :files,
    	  :notes,
    	  resources: ^resources_query]],
      order_by: cu.index)
      |> Repo.all()
  end

  @doc """
  Returns total number of bytes currently used for
  file storage by a user.

  Takes a valid user_id as an integer.

  ## Examples

      iex> get_disk_usage()
      235

  """
  def get_disk_usage(user_id) do
    from(
      f in Files.File,
      where: f.user_id == ^user_id,
      select: f.size)
      |> Repo.all()
      |> Enum.sum()
  end

  @doc """
  High-level function for creating a new user account.

  Takes a unique email address as a string and a full name as a string.

  Creates a user record, an "Inbox" collection for that user, and a
  collections_users record to associate the two.

  ## Example

      iex> make_user("hsolo@ra.net", "Solo, Han")
      %Core.Accounts.User{}

      iex> make_user("existing_email", "fullname")
      {:error, %Ecto.Changeset{}}

  """
  def make_user(email, fullname) do
    with {:ok, user} <- create_user(%{email: email, fullname: fullname}),
	 {:ok, collection} <- Collections.create_collection(
	   %{creator_id: user.id,
	     permalink: Ecto.UUID.generate(),
	     title: "Inbox",
	     write_users: [user.fullname]})
      do CollectionsUsers.create_collection_user(
	    %{user_id: user.id,
	      collection_id: collection.id,
	      index: 0,
	      write_access: true})
      user
    end
  end

  def add_by_csv(file_path) do
    current_users =
      from(u in User, select: u.email)
      |> Repo.all()

    csv_list =
      File.stream!(file_path)
      |> CSV.decode!()
      |> Enum.to_list()

    added_users =
    for [a, b] <- csv_list,
      a not in current_users,
      do: make_user(a, b)

    {Enum.count(added_users), added_users}
  end

  def remove_by_csv(file_path) do
    current_users =
      from(u in User, select: u.email)
      |> Repo.all()

    csv_list =
      File.stream!(file_path)
      |> CSV.decode!()
      |> Enum.to_list()

    csv_emails = for [a, _] <- csv_list, do: a

    removed_users =
    for a <- current_users,
      a in csv_emails,
      do: delete_by_email(a)

    {Enum.count(removed_users), removed_users}
  end

  defp delete_by_email(email) do
    Repo.get_by!(User, email: email)
    |> remove_user()
  end

  def update_by_csv(file_path) do
    # NOTE:   Currently only updates fullname
    current_users =
      from(u in User, select: [u.email, u.fullname])
      |> Repo.all()

    csv_list =
      File.stream!(file_path)
      |> CSV.decode!()
      |> Enum.to_list()

    updated_users =
    for [a, b] <- current_users, [x, y] <- csv_list,
      a == x && b != y,
      do: update_by_email(x, y)

    {Enum.count(updated_users), updated_users}
  end

  defp update_by_email(email, fullname) do
    Repo.get_by!(User, email: email)
    |> update_user(%{fullname: fullname})
  end

  @doc """
  High-level function for syncing a list of user accounts in a file with 
  the database.
  
  Takes a csv file, specified by file path as a string, with one user 
  account per row, with each row formatted as:

  email,"fullname"

  Iterates over the file, skipping every row for which a user account already
  exists for the given email value and creating a user account, with
  associated Inbox collection, for every row with a new email value.

  ## Example

      iex> sync_from_csv("/path/to/users.csv")

  """
  def sync_from_csv(file_path) do
    current_users =
      from(u in Core.Accounts.User, select: u.email)
      |> Core.Repo.all()

    File.stream!(file_path)
    |> CSV.decode!()
    |> Enum.reject(fn [email, _] -> email in current_users end)
    |> Enum.each(fn [email, fullname] -> make_user(email, fullname) end)
  end

  @doc """
  Returns the value of the highest collections_users index for a given user id.
  Used by functions that create new collections for a given user and must
  calculate and assign a higher index value.

  Takes a valid user id as an integer.

  Returns the collections_users index as an integer.

  ## Example

      iex> get_highest_collections_users_index(2)
      3

  """
  def get_highest_collections_users_index(user_id) do
    from(
      cu in Core.Collections.CollectionsUsers,
      where: cu.user_id == ^user_id,
      select: cu.index,
      order_by: cu.index
    )
    |> Core.Repo.all()
    |> Enum.at(-1)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
