defmodule Core.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :file_url, :string
    field :media_type, :string
    field :size, :integer
    field :title, :string
    field :uuid, :string

    belongs_to :collection, Core.Collections.Collection
    belongs_to :resource,   Core.Resources.Resource
    belongs_to :user,       Core.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:file_url, :media_type, :size, :title, :uuid, :collection_id, :resource_id, :user_id])
    |> validate_required([:title, :uuid])
  end
end
