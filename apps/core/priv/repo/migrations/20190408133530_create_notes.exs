defmodule Core.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :body, :text
      add :collection_id, references(:collections, on_delete: :delete_all)
      add :resource_id, references(:resources, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create unique_index("notes", :collection_id)
    create unique_index("notes", :resource_id)
  end
end
