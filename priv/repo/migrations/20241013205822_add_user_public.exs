defmodule Bookify.Repo.Migrations.AddUserPublic do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :public, :boolean, default: true
    end
  end
end
