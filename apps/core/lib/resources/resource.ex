defmodule Core.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :call_number, :string
    field :catalog_url, :string
    field :collection_index, :integer # For ordering of rscs in a collection
    field :contributor, {:array, :string}
    field :coverage, :string
    field :creator, {:array, :string}
    field :date, :string
    field :description, :string
    field :direct_url, :string
    field :doi, :string
    field :ext_collection, :string # "Collection" as understood by Dublin Core
    field :format, :string
    field :identifier, :string
    field :is_part_of, :string
    field :issue, :string
    field :journal, :string
    field :language, :string
    field :page_end, :string
    field :page_start, :string
    field :pages, :string
    field :publisher, :string
    field :relation, :string
    field :rights, :string
    field :save_from_catalog, :map
    field :series, :string
    field :source, :string
    field :subject, {:array, :string}
    field :tags, {:array, :string}, default: []
    field :title, :string, null: false
    field :type, :string
    field :volume, :string

    belongs_to :collection,  Core.Collections.Collection
    has_one    :notes,       Core.Notes.Note
    has_many   :files,       Core.Files.File

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:call_number, :catalog_url, :collection_index, :collection_id, :contributor, :coverage, :creator, :date, :description, :direct_url, :doi, :ext_collection, :format, :identifier, :is_part_of, :issue, :journal, :language, :page_end, :page_start, :pages, :publisher, :relation, :rights, :series, :source, :subject, :tags, :title, :type, :volume])
    |> validate_required([:title])
  end
end
