defmodule Core.CollectionsUsers.CollectionUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "collections_users" do
    field :archived, :boolean, default: false
    field :cloned_from, :string
    field :color, :string
    field :index, :integer # For ordering collections for a given user
    field :pending_approval, :boolean, default: false
    field :write_access, :boolean, default: false

    belongs_to :user,       Core.Accounts.User
    belongs_to :collection, Core.Collections.Collection

    timestamps()
  end

  @doc false
  def changeset(collection_user, attrs) do
    collection_user
    |> cast(attrs, [:archived, :cloned_from, :collection_id, :color, :index, :pending_approval, :user_id, :write_access])
    |> validate_required([])
  end
end
