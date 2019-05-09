defmodule Core.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :collection_id, references(:collections, on_delete: :nilify_all)
      add :file_url, :text
      add :media_type, :text
      add :resource_id, references(:resources, on_delete: :nilify_all)
      add :size, :integer
      add :title, :text
      add :uploader_id, references(:users, on_delete: :nothing), null: false
      add :uuid, :text

      timestamps(type: :timestamptz)
    end

    create index("files", :uploader_id)
    create index("files", :collection_id)
    create index("files", :resource_id)
  end
end
