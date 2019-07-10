defmodule Core.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :call_number, :string
      add :catalog_url, :text
      add :collection_index, :integer
      add :contributor, {:array, :string}
      add :coverage, :text
      add :creator, {:array, :string}
      add :date, :string
      add :description, :text
      add :direct_url, :text
      add :doi, :string
      add :ext_collection, :text
      add :format, :text
      add :identifier, :text
      add :is_part_of, :text
      add :issue, :string
      add :journal, :string
      add :language, :string
      add :page_end, :string
      add :page_start, :string
      add :pages, :string
      add :publisher, :string
      add :relation, :text
      add :rights, :text
      add :series, :text
      add :source, :text
      add :subject, {:array, :text}
      add :tags, {:array, :string}, default: []
      add :title, :text, null: false
      add :type, :text
      add :volume, :string
      add :collection_id, references(:collections, on_delete: :delete_all)

      timestamps()
    end

    create index(:resources, [:collection_id])
    create index(:resources, [:tags])
  end
end
