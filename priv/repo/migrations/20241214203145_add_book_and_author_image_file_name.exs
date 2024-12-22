defmodule Bookify.Repo.Migrations.AddBookAndAuthorImageFileName do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :cover_image_filename, :string
    end

    alter table(:authors) do
      add :image_filename, :string
    end
  end
end
