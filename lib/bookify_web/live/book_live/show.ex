defmodule BookifyWeb.BookLive.Show do
  use BookifyWeb, :live_view

  alias Bookify.Books
  alias Bookify.Books.Book

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"isbn" => isbn}, _url, socket) do
    case Books.get_book_by_isbn(isbn, [:author]) do
      book = %Book{} ->
        {:noreply, assign(socket, :book, book)}

      {:error, {:not_found, message}} ->
        {:noreply, assign(socket, book: nil, error: message)}
    end
  end
end
