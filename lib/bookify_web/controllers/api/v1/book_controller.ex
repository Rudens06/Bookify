defmodule BookifyWeb.Api.V1.BookController do
  use BookifyWeb, :controller

  import Bookify.Utils.Image

  alias Bookify.Books
  alias Bookify.Books.Book

  action_fallback BookifyWeb.FallbackController

  @default_limit "50"
  @max_limit "100"
  @default_offset "0"

  def index(conn, params) do
    limit = limit(params)
    offset = offset(params)

    books =
      Books.list_books(limit, offset)
      |> Enum.map(&put_full_image_url/1)

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
        book = put_full_image_url(book)
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

  defp limit(params) do
    case Map.get(params, "limit", @default_limit)
         |> Integer.parse() do
      {limit, _} ->
        if limit > @max_limit, do: @default_limit, else: limit

      :error ->
        @default_limit
    end
  end

  defp offset(params) do
    case Map.get(params, "offset", @default_offset)
         |> Integer.parse() do
      {offset, _} ->
        offset

      :error ->
        @default_offset
    end
  end

  defp put_full_image_url(book) do
    Map.put(book, :cover_image_url, full_url(book.cover_image_filename))
  end
end
