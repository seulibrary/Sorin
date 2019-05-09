defmodule Core.Repo.Migrations.CreateCollectionsUsers do
  use Ecto.Migration

  def change do
    create table(:collections_users) do
      add :archived, :boolean, default: false, null: false
      add :cloned_from, :string
      add :collection_id, references(:collections, on_delete: :delete_all)
      add :color, :string
      add :index, :integer
      add :pending_approval, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :write_access, :boolean, default: false, null: false

      timestamps(type: :timestamptz)
    end

    create index("collections_users", :collection_id)
    create index("collections_users", :user_id)
    create index("collections_users", :index)
    create unique_index("collections_users", [:collection_id, :user_id])
  end
end
