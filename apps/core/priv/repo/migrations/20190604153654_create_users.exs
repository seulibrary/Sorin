defmodule Core.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :fullname, :string, null: false
      add :organization_id, :string
      add :photo_url, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:organization_id])
  end
end
