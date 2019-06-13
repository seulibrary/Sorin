defmodule Core.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :body, :text
      add :collection_id, references(:collections, on_delete: :delete_all)
      add :resource_id, references(:resources, on_delete: :delete_all)

      timestamps()
    end

    create index(:notes, [:collection_id])
    create index(:notes, [:resource_id])
  end
end
