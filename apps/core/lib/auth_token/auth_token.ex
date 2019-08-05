defmodule Core.AuthTokens.AuthToken do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:token, :use_count, :label]}

  schema "auth_tokens" do
    field :token, :map
    field :use_count, :integer, default: 0
    field :type, :string
    field :label, :string

    belongs_to :user, Core.Accounts.User

  end

  @doc false
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token, :type, :user_id, :use_count, :label])
    |> validate_required([:token, :type, :user_id])
    |> unique_constraint(:token)
  end
end
