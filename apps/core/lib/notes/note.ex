defmodule Core.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :body, :string

    belongs_to :collection, Core.Collections.Collection
    belongs_to :resource,   Core.Resources.Resource

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :collection_id, :resource_id])
    |> validate_required([:body])
  end
end
