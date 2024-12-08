defmodule BookifyWeb.BookLive.Show do
  use BookifyWeb, :live_view

  alias Bookify.Books
  alias Bookify.Books.Book

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"isbn" => isbn}, _url, socket) do
    socket =
      case Books.get_book_by_isbn(isbn, [:author]) do
        book = %Book{} ->
          assign(socket, :book, book)

        {:error, _} ->
          socket
          |> put_flash(:error, "Book not found")
          |> push_navigate(to: ~p"/")
      end

    {:noreply, socket}
  end
end
