defmodule Bookify.Books do
  import Ecto.Query, warn: false
  alias Bookify.Repo

  alias Bookify.Books.Book

  def list_books(preloads \\ []) do
    Repo.all(Book)
    |> Repo.preload(preloads)
  end

  def get_book!(id), do: Repo.get!(Book, id)

  def get_book_by_isbn!(isbn, preloads \\ []) do
    Repo.get_by!(Book, isbn: isbn)
    |> Repo.preload(preloads)
  end

  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end
end
