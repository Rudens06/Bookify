defmodule Bookify.Books do
  import Ecto.Query, warn: false
  alias Bookify.Repo
  alias Bookify.Books.Book

  @not_found_message "Book not found"

  def list_books(limit, offset, preloads \\ []) do
    base_book_query(preloads)
    |> limit(^limit)
    |> offset(^offset)
    |> order_by([b], asc: b.title)
    |> Repo.all()
  end

  def search_books(query, limit, offset, preloads \\ []) do
    search_term = "%#{query}%"

    base_book_query(preloads)
    |> join(:inner, [b], a in assoc(b, :author))
    |> where([b, a], ilike(b.title, ^search_term) or ilike(a.name, ^search_term))
    |> limit(^limit)
    |> offset(^offset)
    |> order_by([b], asc: b.title)
    |> Repo.all()
  end

  def get_book!(id, preloads \\ []) do
    base_book_query(preloads)
    |> where([b], b.id == ^id)
    |> Repo.one!()
  end

  def get_book(id, preloads \\ []) do
    case base_book_query(preloads)
         |> where([b], b.id == ^id)
         |> Repo.one() do
      nil -> not_found()
      book -> book
    end
  end

  def get_book_by_isbn(isbn, preloads \\ []) do
    case base_book_query(preloads)
         |> where([b], b.isbn == ^isbn)
         |> Repo.one() do
      nil -> not_found()
      book -> book
    end
  end

  def preload(book, preloads) do
    Repo.preload(book, preloads)
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

  defp base_book_query(preloads) do
    from b in Book,
      left_join: r in assoc(b, :reviews),
      group_by: b.id,
      preload: ^preloads,
      select: %{
        b
        | avg_rating: coalesce(avg(r.rating), 0.0),
          review_count: count(r.id)
      }
  end

  defp not_found() do
    {:error, {:not_found, @not_found_message}}
  end
end
