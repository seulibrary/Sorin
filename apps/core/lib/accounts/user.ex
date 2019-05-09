defmodule Core.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :fullname, :string
    field :photo_url, :string
    field :token, :string
    field :auth_token, :map

    many_to_many :collections, Core.Collections.Collection,
      join_through: Core.Collections.CollectionsUsers

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :fullname, :photo_url, :token, :auth_token])
    |> validate_required([:email, :fullname])
    |> unique_constraint(:email)
  end
end
