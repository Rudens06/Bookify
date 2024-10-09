defmodule Bookify.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :title, :string, null: false
      add :body, :string
      add :rating, :float, null: false
      add :status, :string, default: "approved"
      add :book_id, references(:books, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:reviews, [:book_id])
    create index(:reviews, [:user_id])
  end
end
