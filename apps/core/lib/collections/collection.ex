defmodule Core.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset


  schema "collections" do
    field :clones_count, :integer, default: 0
    field :creator_id, :id
    field :imports_count, :integer, default: 0
    field :permalink, :string
    field :provenance, :string # To record timestamp and creator on import
    field :published, :boolean, default: false
    field :tags, {:array, :string}, default: []
    field :title, :string
    field :write_users, {:array, :string} # Records who has write access

    has_one      :notes,     Core.Notes.Note
    has_many     :files,     Core.Files.File
    has_many     :resources, Core.Resources.Resource
    many_to_many :users,     Core.Accounts.User,
      join_through: Core.Collections.CollectionsUsers

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:clones_count, :creator_id, :imports_count, :permalink, :provenance, :published, :tags, :title, :write_users])
    |> validate_required([:permalink, :title])
  end
end
