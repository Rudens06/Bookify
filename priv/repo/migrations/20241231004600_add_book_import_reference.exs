defmodule Bookify.Repo.Migrations.AddBookImportReference do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add(:imported_from, :string)
    end
  end
end
