defmodule Core.Repo.Migrations.CreateCollections do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :clones_count, :integer, default: 0
      add :creator_id, references(:users, on_delete: :nothing)
      add :imports_count, :integer, default: 0
      add :permalink, :text, null: false
      add :provenance, :text # Used when a collection is imported by another user
      add :published, :boolean, default: false, null: false
      add :tags, {:array, :string}, default: []
      add :title, :text, null: false
      add :write_users, {:array, :string} # Records who has write access

      timestamps(type: :timestamptz)
    end

    create index("collections", :tags)
    create unique_index("collections", [:permalink])
  end
end
