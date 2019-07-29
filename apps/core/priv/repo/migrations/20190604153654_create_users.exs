defmodule Core.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text, null: false
      add :fullname, :text, null: false
      add :organization_id, :text
      add :photo_url, :text
      add :type, :text

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:organization_id])
  end
end
