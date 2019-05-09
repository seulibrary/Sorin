defmodule Core.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :auth_token, :map
      add :email, :text, null: false
      add :fullname, :text, null: false
      add :photo_url, :text
      add :token, :text

      timestamps(type: :timestamptz)
    end

    create unique_index("users", :email)
  end
end
