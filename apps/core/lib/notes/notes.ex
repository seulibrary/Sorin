defmodule Core.Notes do
  @moduledoc """
  The Notes context.
  """
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Notes.Note

  ###############################
  # CUSTOM FUNCTIONS
  ########

  @doc """
  Updates a note by its ID. Notes can more generically be updated with
  Notes.update_note(); update_note_by_id() is provided as a convenience
  for development in iex.

  Takes a valid note id as an integer and a string that will replace the
  body of the note.

  Returns a tagged tuple with either the updated note struct or a changeset.

  ## Examples

      iex> update_note_by_id(note_id, string)
      {:ok, %Note{}}

      iex> update_note([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def update_note_by_id(note_id, string) do
    get_note!(note_id)
    |> update_note(%{body: string})
  end

  @doc """
  Deletes a note by its ID. Notes can more generically be deleted with
  Notes.delete_note(); delete_note_by_id() is provided as a convenience
  for development in iex.

  Takes a valid note id as an integer.

  Returns a tagged tuple with either the deleted note struct or a changeset.

  ## Examples

      iex> delete_note_by_id(note_id)
      {:ok, %Note{}}

      iex> delete_note(bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def remove_note_by_id(note_id) do
    get_note!(note_id)
    |> delete_note()
  end

  @doc """
  Gets a note by its id and creates a new note with the same body content
  on the specified collection.

  Takes a valid note id as an integer and a valid collection id as an integer.

  Returns a tagged tuple with either the created note struct or a changeset.

  ## Examples

      iex> import_note_to_collection(note_id, collection_id)
      {:ok, %Note{}}

      iex> import_note_to_collection([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def import_note_to_collection(note_id, collection_id) do
    note =
      get_note!(note_id)

    create_note(%{collection_id: collection_id, body: note.body})
  end

  @doc """
  Gets a note by its id and creates a new note with the same body content
  on the specified resource.

  Takes a valid note id as an integer and a valid resource id as an integer.

  Returns a tagged tuple with either the created note struct or a changeset.

  ## Examples

      iex> import_note_to_resource(note_id, resource_id)
      {:ok, %Note{}}

      iex> import_note_to_resource([one or more bad values])
      {:error, %Ecto.Changeset{}}

  """
  def import_note_to_resource(note_id, resource_id) do
    note =
      get_note!(note_id)

    create_note(%{resource_id: resource_id, body: note.body})
  end

  ###############################
  # GENERATED FUNCTIONS
  ###########
  
  @doc """
  Returns the list of notes.

  ## Examples

      iex> list_notes()
      [%Note{}, ...]

  """
  def list_notes do
    Repo.all(Note)
  end

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id), do: Repo.get!(Note, id)

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(%{field: value})
      {:ok, %Note{}}

      iex> create_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Note.

  ## Examples

      iex> delete_note(note)
      {:ok, %Note{}}

      iex> delete_note(note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(note)
      %Ecto.Changeset{source: %Note{}}

  """
  def change_note(%Note{} = note) do
    Note.changeset(note, %{})
  end
end
