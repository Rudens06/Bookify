defmodule Bookify.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string, null: false
      add :isbn, :string, null: false
      add :genres, {:array, :string}
      add :publish_year, :integer, null: false
      add :page_count, :integer, null: false
      add :cover_image_url, :string
      add :anotation, :string, null: false
      add :author_id, references(:authors, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:books, [:author_id])
    create unique_index(:books, [:isbn])
  end
end
