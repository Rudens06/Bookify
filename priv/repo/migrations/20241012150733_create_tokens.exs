defmodule Bookify.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :token, :string, null: false
      add :context, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:user_tokens, :token)
  end
end
