defmodule Bookify.Repo.Migrations.AnotationAndBiographyToText do
  use Ecto.Migration

  def change do
    alter table(:authors) do
      modify :biography, :text
    end

    alter table(:books) do
      modify :anotation, :text
    end
  end
end
