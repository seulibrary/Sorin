defmodule Core.Collections.CollectionsUsers do
  use Ecto.Schema
  import Ecto.Changeset

  #@primary_key false
  schema "collections_users" do
    field :archived, :boolean, default: false
    field :cloned_from, :string
    field :color, :string
    field :index, :integer # Position of collection for a given user
    field :pending_approval, :boolean, default: false
    field :write_access, :boolean, default: false

    belongs_to :user,       Core.Accounts.User
    belongs_to :collection, Core.Collections.Collection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collections_users, attrs) do
    collections_users
    |> cast(attrs, [:archived, :cloned_from, :color,
		   :index, :pending_approval, :write_access,
		   :user_id, :collection_id])
    |> validate_required([])
    # The following unique_constraint is provided so that violations
    # of the constraint trigger an actual error.
    |> unique_constraint(:collection_id,
    name: :collections_users_collection_id_user_id_index)
  end
end
