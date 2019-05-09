defmodule Core.Files do
  @moduledoc """
  The Files context.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  #################################
  # CUSTOM FUNCTIONS
  ########

  @doc """
  High-level function for uploading a file to a specified resource or
  collection.

  Takes a file path as a string or map, a valid user id as an integer,
  a :resource or :collection atom, and the id of the collection or
  resource as an integer.

  Gets the file size and checks whether the upload would not put the 
  specified user over their storage quota; if so, returns an error. If 
  not, passes the relevant arguments to upload_file_to_s3(), which generates
  or gets several values for the file, uploads it to S3, creates a database
  record for it, and returns the struct.

  ## Examples

      iex> upload_file("/home/rgibbs/a_file", user_id, :resource, resource_id)
      {:ok, %File{}}

  """
  def upload_file(path, user_id, resource_or_collection_atom, target_id) when is_map(path) do
    file_size = byte_size(path.binary)
    if Core.Accounts.get_disk_usage(user_id) + file_size <= Application.get_env(:ex_aws, :disk_quota) do
      upload_file_to_s3(path.binary, path.filename, file_size, user_id, resource_or_collection_atom, target_id)
    else
      {:error, "This upload would exceed your disk usage quota. You are currently using approximately #{Float.round(Core.Accounts.get_disk_usage(user_id)/1000/1000, 4)} MB of your allotted 1000 MB."}
    end
  end

  def upload_file(path, user_id, resource_or_collection_atom, target_id) do
    file_size = file_size(path)

    if Core.Accounts.get_disk_usage(user_id) + file_size <= Application.get_env(:ex_aws, :disk_quota) do
      upload_file_to_s3(path, Path.basename(path), file_size, user_id, resource_or_collection_atom, target_id)
    else
      {:error, "This upload would exceed your disk usage quota. You are currently using approximately #{Float.round(Core.Accounts.get_disk_usage(user_id)/1000/1000, 4)} MB of your allotted 1000 MB."}
    end
  end

  defp upload_file_to_s3(path, file_name, file_size, user_id, resource_or_collection_atom, target_id) do
    uuid = Ecto.UUID.generate()

    binary = cond do
      is_binary(path) -> path
      true -> File.read!(path)
    end

    ExAws.S3.put_object(Application.get_env(:ex_aws, :bucket), uuid, binary)
    |> ExAws.request()

    case resource_or_collection_atom do
      :resource ->
        create_file(
          %{title: file_name,
            uuid: uuid,
            file_url: "#{Application.get_env(:ex_aws, :link_root)}#{uuid}",
            size: file_size,
            uploader_id: user_id,
            resource_id: target_id})
      :collection ->
        create_file(
          %{title: file_name,
            uuid: uuid,
            file_url: "#{Application.get_env(:ex_aws, :link_root)}#{uuid}",
            size: file_size,
            uploader_id: user_id,
            collection_id: target_id})
    end
  end

  @doc """
  Gets a file's size in bytes, using Elixir's File module.

  Takes a file path as a string.

  ## Examples

      iex> file_size("/home/rgibbs/a_file")
      1612

  """
  def file_size(path) do
    File.stat("#{path}")
    |> elem(1)
    |> Map.get(:size)
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
    |> Core.Repo.get_by(uuid: uuid)
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

      iex> download_file_web(uuid)
      file_as_string

  """
  def download_file_web(file_uuid) do
    {:ok, %{body: body}} =
      ExAws.S3.get_object(Application.get_env(:ex_aws, :bucket), file_uuid)
      |> ExAws.request()

    body
  end


  @doc """
  Downloads a file, specified by its id, to the local directory. Intended to
  be called from iex.

  Takes a valid file id as an integer.

  ## Examples

      iex> download_file(123)
      :ok

  """
  def download_file(file_id) do
    file = get_file!(file_id)

    {:ok, %{body: body}} =
      ExAws.S3.get_object(Application.get_env(:ex_aws, :bucket), file.uuid)
      |> ExAws.request()


    File.write(file.title, body)
  end

  @doc """
  Calls delete_file_by_id() on every file that has no collection_id or
  resource_id.

  ## Examples

      iex> remove_orphaned_files()
      :ok

  """
  def remove_orphaned_files() do
    from(
      f in Core.Files.File,
      where: fragment("collection_id is null and resource_id is null"),
      select: f.id
    )
    |> Core.Repo.all()
    |> Enum.each(fn(x) -> delete_file_by_id(x) end)
  end

  #################################
  # GENERATED FUNCTIONS
  ###########

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
