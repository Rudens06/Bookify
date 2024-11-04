defmodule Bookify.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :hashed_token, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(updated_at: false)
    end

    create unique_index(:tokens, [:hashed_token])
  end
end
