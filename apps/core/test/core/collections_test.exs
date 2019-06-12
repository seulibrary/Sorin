defmodule Core.CollectionsTest do
  use Core.DataCase

  alias Core.Collections

  describe "collections" do
    alias Core.Collections.Collection

    @valid_attrs %{chain_of_cust: ["some chain of cust"], clones_count: 42, import_stamp: "some import stamp", imports_count: 42, permalink: "some permalink", published: true, tags: [], title: "some title", write_users: []}
    @update_attrs %{chain_of_cust: ["some chain of cust", "another entry"], clones_count: 43, import_stamp: "some updated import stamp", imports_count: 43, permalink: "some updated permalink", published: false, tags: ["some tag"], title: "some updated title", write_users: []}
    @invalid_attrs %{chain_of_cust: nil, clones_count: nil, import_stamp: nil, imports_count: nil, permalink: nil, published: nil, tags: nil, title: nil, write_users: nil}

    def collection_fixture(attrs \\ %{}) do
      {:ok, collection} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Collections.create_collection()

      collection
    end

    test "list_collections/0 returns all collections" do
      collection = collection_fixture()
      assert Collections.list_collections() == [collection]
    end

    test "get_collection!/1 returns the collection with given id" do
      collection = collection_fixture()
      assert Collections.get_collection!(collection.id) == collection
    end

    test "create_collection/1 with valid data creates a collection" do
      assert {:ok, %Collection{} = collection} = Collections.create_collection(@valid_attrs)
      assert collection.chain_of_cust == ["some chain of cust"]
      assert collection.clones_count == 42
      assert collection.import_stamp == "some import stamp"
      assert collection.imports_count == 42
      assert collection.permalink == "some permalink"
      assert collection.published == true
      assert collection.tags == []
      assert collection.title == "some title"
      assert collection.write_users == []
    end

    test "create_collection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collections.create_collection(@invalid_attrs)
    end

    test "update_collection/2 with valid data updates the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{} = collection} = Collections.update_collection(collection, @update_attrs)
      assert collection.chain_of_cust == ["some chain of cust", "another entry"]
      assert collection.clones_count == 43
      assert collection.import_stamp == "some updated import stamp"
      assert collection.imports_count == 43
      assert collection.permalink == "some updated permalink"
      assert collection.published == false
      assert collection.tags == ["some tag"]
      assert collection.title == "some updated title"
      assert collection.write_users == []
    end

    test "update_collection/2 with invalid data returns error changeset" do
      collection = collection_fixture()
      assert {:error, %Ecto.Changeset{}} = Collections.update_collection(collection, @invalid_attrs)
      assert collection == Collections.get_collection!(collection.id)
    end

    test "delete_collection/1 deletes the collection" do
      collection = collection_fixture()
      assert {:ok, %Collection{}} = Collections.delete_collection(collection)
      assert_raise Ecto.NoResultsError, fn -> Collections.get_collection!(collection.id) end
    end

    test "change_collection/1 returns a collection changeset" do
      collection = collection_fixture()
      assert %Ecto.Changeset{} = Collections.change_collection(collection)
    end
  end
end
