defmodule Core.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :fullname, :string
    field :organization_id, :string
    field :photo_url, :string
    field :type, :string

    many_to_many :collections, Core.Collections.Collection,
      join_through: Core.CollectionsUsers.CollectionUser

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :fullname, :organization_id, :photo_url, :type])
    |> validate_required([:email, :fullname])
    |> unique_constraint(:email)
    |> unique_constraint(:organization_id)
  end
end
