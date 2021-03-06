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
  High-level function for adding, removing, and updating user accounts
  in the database with those listed in a provided csv file.

  Accounts in the csv file that are not in the database are added;
  accounts that are in the database but not the csv file are removed;
  accounts whose email addresses are the same in the database and the
  csv file but whose fullnames are different have their fullname
  updated in the database to match the fullname in the csv.

  Takes a csv file, specified by file path as a string, with one user
  account per row, with each row formatted as:

  email,"fullname"

  Returns a map with the numbers of added/updated/removed accounts,
  along with the accounts themselves, sorted by the sync action.

  ## Example

      iex> sync_by_csv("/path/to/users.csv")
      {:ok, {:added, 24, [%Core.Accounts.User{}, ...]},
            {:updated, 17, [%Core.Accounts.User{}, ...]},
            {:removed, 3, [%Core.Accounts.User{}, ...]}
      }

  """
  def sync_by_csv(file_path) do
    current_users =
      from(u in User, select: [u.email, u.fullname])
      |> Repo.all()

    current_emails = for [a, _] <- current_users, do: a

    csv_list =
      File.stream!(file_path)
      |> CSV.decode!()
      |> Enum.to_list()

    csv_emails = for [a, _] <- csv_list, do: a

    added_users =
    for [a, b] <- csv_list,
      a not in current_emails,
      do: make_user(a, b)

    removed_users =
    for a <- current_emails,
      a not in csv_emails,
      do: delete_by_email(a)

    updated_users =
    for [a, b] <- current_users, [x, y] <- csv_list,
      a == x && b != y,
      do: update_by_email(x, y)

    {:ok,
     %{added_users: added_users},
     %{removed_users: removed_users},
     %{updated_users: updated_users},
     total_added_users: Enum.count(added_users),
     total_removed_users: Enum.count(removed_users),
     total_updated_users: Enum.count(updated_users),
    }
  end

  @doc """
  Returns the value of the highest collections_users index for a given user id.
  Used by functions that create new collections for a given user and must
  calculate and assign a higher index value.

  Takes a valid user id as an integer.

  Returns the collections_users index as an integer.

  ## Example

      iex> get_highest_col_user_index(2)
      3

  """
  def get_highest_col_user_index(user_id) do
    from(
      cu in CollectionUser,
      where: cu.user_id == ^user_id,
      select: cu.index,
      order_by: cu.index
    )
    |> Repo.all()
    |> Enum.at(-1)
  end

  @doc """
  Removes a user: removes their files, deletes their Inbox, unpublishes
  collections they're the creator and sole write_user of, removes
  them from all write_users fields they're currently in, updates
  the chain_of_cust on all collections they're leaving, decrements
  the clones_count of all clones that will be deleted, and deletes
  them from the database, which also deletes all of their
  CollectionsUsers records and nilifies all of the creator_id fields.

  ## Examples

      iex> remove_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def remove_user(%User{} = user) do
    #
    # Q. WHY IS THIS FUNCTION SO CRAZY?
    #
    # A. I'm glad you asked. The main reason why this function is so long,
    #    complicated, and obtuse is that its general purpose is to remove
    #    most (but not all!) traces of the user from the database, while
    #    still leaving their collections available at their permalinks.
    #
    #    To facilitate this, remove_user/1 does six things:
    #
    #    - Removes the supplied user's files from both the database and remote
    #      storage;
    #    - Deletes their Inbox, access to which it is not assumed will be
    #      needed at its permalink;
    #    - Unpublishes collections where the supplied user is the creator
    #      and sole write_user, to prevent ancient collections from clogging
    #      up search results for perpetuity;
    #    - Removes the user's fullname from the write_users field of all
    #      collections they have write_access to at the time of account
    #      removal (after all, they no longer have write_access, right?), which
    #      also updates the collections' chain_of_cust fields to note the date
    #      on which the user's write_access was revoked;
    #    - Decrements the clones_count field on all clones before they are
    #      removed;
    #    - Finally, deletes the user record from the database, which causes the
    #      database to automatically delete all associated collections_users
    #      rows and nilify all creator_id fields on the user's remaining
    #      collections.

    # Delete files. delete_file_by_id() removes them from the database and
    # remote storage.
    from(f in Files.File,
      where: f.user_id == ^user.id,
      select: f.id)
    |> Repo.all
    |> Enum.each(&Files.delete_file_by_id(&1))

    # Delete the Inbox. Joins on CollectionUser to identify the inbox by its
    # position on the dashboard, which cannot be superceded by the user (vs,
    # e.g., matching on the title "Inbox," which the user could apply to
    # any other collections).
    from(cu in CollectionUser,
      left_join: c in Collection,
      on: cu.collection_id == c.id,
      where: cu.user_id == ^user.id,
      where: cu.index == 0,
      select: c
    )
    |> Core.Repo.one
    |> Collections.delete_collection()

    # Unpublish collections where user is creator and sole write_user.
    # This can be removed if you want a user's published collections to still
    # appear in search results after their account is removed, but bear in
    # mind that there will be no way to remove them except via API or iex.
    solo_filter = [write_users: ["#{user.fullname}"]]
    from(c in Collection,
      where: c.creator_id == ^user.id,
      where: ^solo_filter)
      |> Repo.all
      |> Enum.map(&Collections.update_collection(&1, %{published: false}))

    # Remove the user's fullname from the write_users field of all collections
    # where it is currently found. remove_write_user() updates both the
    # write_users and chain_of_cust fields on the supplied collection.
    from(cu in CollectionUser,
      where: cu.user_id == ^user.id,
      where: cu.write_access == true,
      select: cu.collection_id)
      |> Repo.all
      |> Enum.map(&Collections.remove_write_user(&1, user.id))

    # Decrement the clones_count field on all cloned collections before they
    # are removed.
    from(cu in CollectionUser,
      left_join: c in Collection,
      on: cu.collection_id == c.id,
      where: cu.user_id == ^user.id,
      where: cu.write_access == false,
      select: c
    )
    |> Repo.all()
    |> Enum.map(
      &Collections.update_collection(&1,
	%{clones_count: (&1.clones_count - 1)}))

    # Delete user account, which deletes all CollectionsUsers records for it
    # and nilifies all creator_id fields for it.
    Repo.delete(user)
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
