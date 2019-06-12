defmodule Core.CollectionsUsersTest do
  use Core.DataCase

  alias Core.CollectionsUsers

  describe "collections_users" do
    alias Core.CollectionsUsers.CollectionUser

    @valid_attrs %{archived: true, cloned_from: "some cloned_from", color: "some color", index: 42, pending_approval: true, write_access: true}
    @update_attrs %{archived: false, cloned_from: "some updated cloned_from", color: "some updated color", index: 43, pending_approval: false, write_access: false}
    # The following attribute has been commented out because collections_users
    # changesets are only created by internal code that never passes nil values.
    #
    # @invalid_attrs %{archived: nil, cloned_from: nil, color: nil, index: nil, pending_approval: nil, write_access: nil}

    def collection_user_fixture(attrs \\ %{}) do
      {:ok, collection_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CollectionsUsers.create_collection_user()

      collection_user
    end

    test "list_collections_users/0 returns all collections_users" do
      collection_user = collection_user_fixture()
      assert CollectionsUsers.list_collections_users() == [collection_user]
    end

    test "get_collection_user!/1 returns the collection_user with given id" do
      collection_user = collection_user_fixture()
      assert CollectionsUsers.get_collection_user!(collection_user.id) == collection_user
    end

    test "create_collection_user/1 with valid data creates a collection_user" do
      assert {:ok, %CollectionUser{} = collection_user} = CollectionsUsers.create_collection_user(@valid_attrs)
      assert collection_user.archived == true
      assert collection_user.cloned_from == "some cloned_from"
      assert collection_user.color == "some color"
      assert collection_user.index == 42
      assert collection_user.pending_approval == true
      assert collection_user.write_access == true
    end

    # The following test case has been commented out because collections_users
    # changesets are only created by internal code that never passes nil
    # values.
    #
    # test "create_collection_user/1 with invalid data returns error changeset" do
    #   # Errors on first nil field; does not test the rest
    #   assert {:error, %Ecto.Changeset{}} = CollectionsUsers.create_collection_user(@invalid_attrs)
    # end

    test "update_collection_user/2 with valid data updates the collection_user" do
      collection_user = collection_user_fixture()
      assert {:ok, %CollectionUser{} = collection_user} = CollectionsUsers.update_collection_user(collection_user, @update_attrs)
      assert collection_user.archived == false
      assert collection_user.cloned_from == "some updated cloned_from"
      assert collection_user.color == "some updated color"
      assert collection_user.index == 43
      assert collection_user.pending_approval == false
      assert collection_user.write_access == false
    end

    # The following test case has been commented out because collections_users
    # changesets are only created by internal code that never passes nil
    # values.
    #
    # test "update_collection_user/2 with invalid data returns error changeset" do
    #   collection_user = collection_user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = CollectionsUsers.update_collection_user(collection_user, @invalid_attrs)
    #   assert collection_user == CollectionsUsers.get_collection_user!(collection_user.id)
    # end

    test "delete_collection_user/1 deletes the collection_user" do
      collection_user = collection_user_fixture()
      assert {:ok, %CollectionUser{}} = CollectionsUsers.delete_collection_user(collection_user)
      assert_raise Ecto.NoResultsError, fn -> CollectionsUsers.get_collection_user!(collection_user.id) end
    end

    test "change_collection_user/1 returns a collection_user changeset" do
      collection_user = collection_user_fixture()
      assert %Ecto.Changeset{} = CollectionsUsers.change_collection_user(collection_user)
    end
  end
end
