defmodule Core.FilesTest do
  use Core.DataCase

  alias Core.Files

  describe "files" do
    alias Core.Files.File

    @valid_attrs %{file_url: "some file_url", media_type: "some media_type", size: 42, title: "some title", uuid: "some uuid"}
    @update_attrs %{file_url: "some updated file_url", media_type: "some updated media_type", size: 43, title: "some updated title", uuid: "some updated uuid"}
    @invalid_attrs %{file_url: nil, media_type: nil, size: nil, title: nil, uuid: nil}

    def file_fixture(attrs \\ %{}) do
      {:ok, file} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Files.create_file()

      file
    end

    test "list_files/0 returns all files" do
      file = file_fixture()
      assert Files.list_files() == [file]
    end

    test "get_file!/1 returns the file with given id" do
      file = file_fixture()
      assert Files.get_file!(file.id) == file
    end

    test "create_file/1 with valid data creates a file" do
      assert {:ok, %File{} = file} = Files.create_file(@valid_attrs)
      assert file.file_url == "some file_url"
      assert file.media_type == "some media_type"
      assert file.size == 42
      assert file.title == "some title"
      assert file.uuid == "some uuid"
    end

    test "create_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Files.create_file(@invalid_attrs)
    end

    test "update_file/2 with valid data updates the file" do
      file = file_fixture()
      assert {:ok, %File{} = file} = Files.update_file(file, @update_attrs)
      assert file.file_url == "some updated file_url"
      assert file.media_type == "some updated media_type"
      assert file.size == 43
      assert file.title == "some updated title"
      assert file.uuid == "some updated uuid"
    end

    test "update_file/2 with invalid data returns error changeset" do
      file = file_fixture()
      assert {:error, %Ecto.Changeset{}} = Files.update_file(file, @invalid_attrs)
      assert file == Files.get_file!(file.id)
    end

    test "delete_file/1 deletes the file" do
      file = file_fixture()
      assert {:ok, %File{}} = Files.delete_file(file)
      assert_raise Ecto.NoResultsError, fn -> Files.get_file!(file.id) end
    end

    test "change_file/1 returns a file changeset" do
      file = file_fixture()
      assert %Ecto.Changeset{} = Files.change_file(file)
    end
  end
end
