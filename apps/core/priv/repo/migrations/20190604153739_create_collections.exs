defmodule Core.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :chain_of_cust, {:array, :string}
      add :clones_count, :integer, default: 0
      add :imports_count, :integer, default: 0
      add :import_stamp, :string # Used when a collection is imported
      add :permalink, :string, null: false
      add :published, :boolean, default: false, null: false
      add :tags, {:array, :string}, default: []
      add :title, :string, null: false
      add :write_users, {:array, :string} # Fullnames of users w/write access
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:collections, [:permalink])
    create index(:collections, [:tags])
  end
end
