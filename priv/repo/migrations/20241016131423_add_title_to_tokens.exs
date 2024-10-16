defmodule Bookify.Repo.Migrations.AddTitleToTokens do
  use Ecto.Migration

  def change do
    alter table(:user_tokens) do
      add :title, :string
    end
  end
end
