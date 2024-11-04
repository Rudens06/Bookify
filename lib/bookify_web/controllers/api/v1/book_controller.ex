defmodule BookifyWeb.Api.V1.BookController do
  use BookifyWeb, :controller

  alias Bookify.Books
  alias Bookify.Books.Book

  action_fallback BookifyWeb.FallbackController

  def index(conn, _params) do
    books = Books.list_books()
    render(conn, :index, books: books)
  end

  def create(conn, %{"book" => book_params}) do
    with {:ok, %Book{} = book} <- Books.create_book(book_params) do
      conn
      |> put_status(:created)
      |> render(:show, book: book)
    end
  end

  def show(conn, %{"isbn" => isbn}) do
    book = Books.get_book_by_isbn!(isbn)
    render(conn, :show, book: book)
  end

  def update(conn, %{"isbn" => isbn, "book" => book_params}) do
    book = Books.get_book_by_isbn!(isbn)

    with {:ok, %Book{} = book} <- Books.update_book(book, book_params) do
      render(conn, :show, book: book)
    end
  end

  def delete(conn, %{"isbn" => isbn}) do
    book = Books.get_book_by_isbn!(isbn)

    with {:ok, %Book{}} <- Books.delete_book(book) do
      send_resp(conn, :no_content, "")
    end
  end
end
