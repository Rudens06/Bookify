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
    case Books.get_book_by_isbn(isbn) do
      %Book{} = book ->
        render(conn, :show, book: book)

      error ->
        error
    end
  end

  def update(conn, %{"isbn" => isbn, "book" => book_params}) do
    case Books.get_book_by_isbn(isbn) do
      %Book{} = book ->
        with {:ok, %Book{} = book} <- Books.update_book(book, book_params) do
          render(conn, :show, book: book)
        end

      error ->
        error
    end
  end

  def delete(conn, %{"isbn" => isbn}) do
    case Books.get_book_by_isbn(isbn) do
      %Book{} = book ->
        with {:ok, %Book{}} <- Books.delete_book(book) do
          send_resp(conn, :no_content, "")
        end

      error ->
        error
    end
  end
end
