defmodule Core.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :file_url, :text
      add :media_type, :text
      add :size, :integer
      add :title, :text
      add :uuid, :text
      add :collection_id, references(:collections, on_delete: :nilify_all)
      add :resource_id, references(:resources, on_delete: :nilify_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:files, [:collection_id])
    create index(:files, [:resource_id])
    create index(:files, [:user_id])
  end
end
