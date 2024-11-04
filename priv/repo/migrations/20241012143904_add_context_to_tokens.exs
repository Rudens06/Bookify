defmodule Bookify.Repo.Migrations.AddContextToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :context, :string
    end
  end
end
