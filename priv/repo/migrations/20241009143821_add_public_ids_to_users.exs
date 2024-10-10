defmodule Bookify.Repo.Migrations.AddPublicIdsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :public_id, :string, null: false
    end

    create unique_index(:users, [:public_id])
  end
end
