defmodule Bookify.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string, null: false
      add :birth_year, :integer, null: false
      add :biography, :string, null: false
      add :image_url, :string
      add :wikipedia_url, :string

      timestamps()
    end
  end
end
