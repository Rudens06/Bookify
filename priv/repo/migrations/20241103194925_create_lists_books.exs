defmodule Bookify.Repo.Migrations.CreateBooksInLists do
  use Ecto.Migration

  def change do
    create table(:lists_books, primary_key: false) do
      add :list_id, references(:lists, type: :integer, on_delete: :delete_all), primary_key: true
      add :book_id, references(:books, type: :integer, on_delete: :delete_all), primary_key: true
      add :page_stopped_at, :integer
      add :status, :string
      add :notes, :string

      timestamps()
    end

    create unique_index(:lists_books, [:list_id, :book_id], name: :unique_primary_key)
  end
end
