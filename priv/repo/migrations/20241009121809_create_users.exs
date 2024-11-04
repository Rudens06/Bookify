defmodule Bookify.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :username, :string
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :roles, {:array, :string}, default: []
      add :last_login, :utc_datetime

      timestamps()
    end
  end
end
