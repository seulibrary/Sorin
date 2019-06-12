defmodule Core.Collections.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections" do
    field :chain_of_cust, {:array, :string}
    field :clones_count, :integer, default: 0
    field :imports_count, :integer, default: 0
    field :import_stamp, :string # To record timestamp and creator on import
    field :permalink, :string
    field :published, :boolean, default: false
    field :tags, {:array, :string}, default: []
    field :title, :string
    field :write_users, {:array, :string} # Fullnames of users w/write access
    field :creator_id, :id

    has_one      :notes,     Core.Notes.Note
    has_many     :files,     Core.Files.File
    has_many     :resources, Core.Resources.Resource
    many_to_many :users,     Core.Accounts.User,
      join_through: Core.CollectionsUsers.CollectionUser

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:chain_of_cust, :clones_count, :creator_id, :imports_count, :import_stamp, :permalink, :published, :tags, :title, :write_users])
    |> validate_required([:permalink, :title])
  end
end
