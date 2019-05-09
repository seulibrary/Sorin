defmodule Core.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :call_number, :text
      add :catalog_url, :text
      add :collection_id, references(:collections, on_delete: :delete_all)
      add :collection_index, :integer
      add :contributor, {:array, :text}
      add :coverage, :text
      add :creator, {:array, :text}
      add :date, :text
      add :description, :text
      add :direct_url, :text
      add :doi, :text
      add :ext_collection, :text
      add :format, :text
      add :identifier, :text
      add :is_part_of, :text
      add :issue, :text
      add :journal, :text
      add :language, :text
      add :page_end, :text
      add :page_start, :text
      add :pages, :text
      add :publisher, :text
      add :relation, :text
      add :rights, :text
      add :series, :text
      add :source, :text
      add :subject, {:array, :text}
      add :tags, {:array, :text}, default: []
      add :title, :text
      add :type, :text
      add :volume, :text

      timestamps(type: :timestamptz)
    end

    create index("resources", :collection_id)
    create index("resources", :collection_index)
    create index("resources", :tags)
  end
end
