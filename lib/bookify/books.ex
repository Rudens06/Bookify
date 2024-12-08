defmodule Bookify.Books do
  import Ecto.Query, warn: false
  alias Bookify.Repo

  alias Bookify.Books.Book

  @not_found_message "Book not found"

  def list_books(preloads \\ []) do
    Repo.all(Book)
    |> Repo.preload(preloads)
  end

  def search_books(query, preloads \\ []) do
    query = "%#{query}%"

    Repo.all(
      from b in Book,
        join: a in assoc(b, :author),
        where: ilike(b.title, ^query) or ilike(a.name, ^query),
        preload: ^preloads
    )
  end

  def get_book!(id), do: Repo.get!(Book, id)

  def get_book(id) do
    case Repo.get(Book, id) do
      nil ->
        not_found()

      book ->
        book
    end
  end

  def get_book_by_isbn(isbn, preloads \\ []) do
    case Repo.get_by(Book, isbn: isbn)
         |> Repo.preload(preloads) do
      nil ->
        not_found()

      book ->
        book
    end
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

  defp not_found() do
    {:error, {:not_found, @not_found_message}}
  end
end
