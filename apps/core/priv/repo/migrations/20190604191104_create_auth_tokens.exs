defmodule Core.Repo.Migrations.CreateAuthTokens do
  use Ecto.Migration

  def change do
    create table(:auth_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :map
      add :use_count, :integer
      add :label, :string
      add :type, :string

      timestamps(type: :timestamptz)
    end

    create unique_index("auth_tokens", :token)
  end
end
