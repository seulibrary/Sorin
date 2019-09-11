defmodule Core.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :chain_of_cust, {:array, :text}, default: []
      add :clones_count, :integer, default: 0
      add :imports_count, :integer, default: 0
      add :import_stamp, :text # Used when a collection is imported
      add :permalink, :text, null: false
      add :published, :boolean, default: false, null: false
      add :tags, {:array, :text}, default: []
      add :title, :text, null: false
      add :write_users, {:array, :text} # Fullnames of users w/write access
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:collections, [:permalink])
    create index(:collections, [:tags])
  end
end
