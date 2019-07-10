defmodule Core.Files do
  @moduledoc """
  The Files context.
  """
  import Ecto.Query, warn: false
  alias Core.{
    Accounts,
    Repo,
  }

  @doc """
  High-level function for uploading a file to a specified resource or
  collection.

  Takes (1) a map containing values for the keys filename and binary,
  where the value of the binary key is the file as a binary; (2) a
  valid user id as an integer, (3) a :resource or :collection atom,
  and (4) the id of the collection or resource as an integer.

  Gets the file size and checks whether the upload would put the
  specified user over their storage quota; if so, returns an error. If
  not, uploads the file to remote storage, creates a database record
  for it, and returns the new file struct.

  ## Examples

      iex> upload_file(%{}, user_id, :resource, resource_id)
      {:ok, %File{}}

      iex> upload_file(too_large_file, user_id, :resource, resource_id)
      {:error, "This upload would exceed your disk usage quota. You are
           currently using approximately 999 MB of your allotted
           1000 MB, and this file is 2 MB."

  """
  def upload_file(file_map, user_id, :resource, resource_id) do
    uuid = Ecto.UUID.generate()
    upload_target = Application.get_env(:ex_aws, :bucket)
    file_size = byte_size(file_map.binary)

    with true <- under_quota?(file_size, user_id) do
      ExAws.S3.put_object(upload_target, uuid, file_map.binary)
      |> ExAws.request()

      create_file(%{
        title: file_map.filename,
        uuid: uuid,
        file_url: "#{Application.get_env(:ex_aws, :link_root)}#{uuid}",
        size: byte_size(file_map.binary),
        user_id: user_id,
        resource_id: resource_id
      })
    end
  end

  def upload_file(file_map, user_id, :collection, collection_id) do
    uuid = Ecto.UUID.generate()
    upload_target = Application.get_env(:ex_aws, :bucket)
    file_size = byte_size(file_map.binary)

    with true <- under_quota?(file_size, user_id) do
      ExAws.S3.put_object(upload_target, uuid, file_map.binary)
      |> ExAws.request()

      create_file(%{
        title: file_map.filename,
        uuid: uuid,
        file_url: "#{Application.get_env(:ex_aws, :link_root)}#{uuid}",
        size: byte_size(file_map.binary),
        user_id: user_id,
        collection_id: collection_id
      })
    end
  end

  defp under_quota?(file_size, user_id) do
    current_disk_usage = Accounts.get_disk_usage(user_id)
    human_friendly_current = Float.round(current_disk_usage / 1_000_000, 4)
    proposed_disk_usage = current_disk_usage + file_size
    quota = Application.get_env(:ex_aws, :disk_quota)
    human_friendly_quota = quota / 1_000_000

    case proposed_disk_usage <= quota do
      true ->
        true

      false ->
        {:error,
         "This upload would exceed your disk usage quota. You are " <>
           "currently using approximately #{human_friendly_current} MB " <>
           "of your allotted #{human_friendly_quota} MB, and this file " <>
           "is #{file_size} MB."}
    end
  end

  @doc """
  Gets a file struct by the value of its UUID field.

  ## Examples

      iex> get_file_by_uuid("valid_uuid")
      %File{}

      iex> get_file_by_uuid("invalid_uuid")
      nil

  """
  def get_file_by_uuid(uuid) do
    Core.Files.File
    |> Repo.get_by(uuid: uuid)
  end

  @doc """
  High-level function for deleting files.

  Takes a valid file id as an integer. 

  Deletes the file's record from the database, then deletes it from S3.

  ## Examples

      iex> delete_file_by_id(file_id)
      {:ok, %{}}

  """
  def delete_file_by_id(file_id) do
    file = get_file!(file_id)
    Repo.delete(file)

    ExAws.S3.delete_object(Application.get_env(:ex_aws, :bucket), file.uuid)
    |> ExAws.request()
  end

  @doc """
  Downloads a file, specified by its uuid, from S3. Intended to be called from
  Sorin's front end.

  Takes the requested file's uuid as a string.

  ## Examples

      iex> download_file_by_uuid(uuid)
      "[file as string of bytes]"

  """
  def download_file_by_uuid(uuid) do
    {:ok, %{body: body}} =
      ExAws.S3.get_object(Application.get_env(:ex_aws, :bucket), uuid)
      |> ExAws.request()

    body
  end

  @doc """
  Calls delete_file_by_id() on every file that has no collection_id or
  resource_id.

  Returns a tagged tuple with the number of files deleted.

  ## Examples

      iex> remove_orphaned_files()
      {:ok, 7}

  """
  def remove_orphaned_files() do
    removed_files =
      from(
        f in Core.Files.File,
        where: fragment("collection_id is null and resource_id is null"),
        select: f.id
      )
      |> Repo.all()

    Enum.each(removed_files, &delete_file_by_id(&1))

    {:ok, Enum.count(removed_files)}
  end

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%File{}, ...]

  """
  def list_files do
    Repo.all(Core.Files.File)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id), do: Repo.get!(Core.Files.File, id)

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs \\ %{}) do
    %Core.Files.File{}
    |> Core.Files.File.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%Core.Files.File{} = file, attrs) do
    file
    |> Core.Files.File.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a File.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%Core.Files.File{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{source: %File{}}

  """
  def change_file(%Core.Files.File{} = file) do
    Core.Files.File.changeset(file, %{})
  end
end
