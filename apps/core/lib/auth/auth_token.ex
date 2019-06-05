defmodule Core.Auth.AuthToken do
  use Ecto.Schema
  import Ecto.Changeset


  schema "auth_tokens" do
    field :token, :map
    field :use_count, :integer, default: 0
    field :type, :string

    belongs_to :user, Core.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token, :type])
    |> validate_required([:token, :type])
    |> unique_constraint(:token)
  end
end
