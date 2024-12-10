defmodule BookifyWeb.BookLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Book

  alias Bookify.Books
  alias Bookify.Authors
  alias Bookify.Books.Book

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"isbn" => isbn}, _url, socket) do
    socket =
      case Books.get_book_by_isbn(isbn, [:author]) do
        book = %Book{} ->
          authors =
            Authors.list_authors()
            |> select_options()

          socket
          |> assign(:book, book)
          |> assign(:authors, authors)
          |> assign(:page_title, page_title(socket.assigns.live_action))

        {:error, {:not_found, message}} ->
          socket
          |> put_flash(:error, message)
          |> push_navigate(to: ~p"/")
      end

    {:noreply, socket}
  end

  def handle_event("edit_book", _params, socket) do
    book = socket.assigns.book
    {:noreply, push_navigate(socket, to: ~p"/books/#{book.isbn}/show/edit")}
  end

  def handle_event("delete_book", _params, socket) do
    book = socket.assigns.book

    socket =
      case Books.delete_book(book) do
        {:ok, _} ->
          put_flash(socket, :info, "Book deleted successfully")

        {:error, _} ->
          put_flash(socket, :error, "Something went wrong")
      end

    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  defp page_title(:show), do: "Show Book"
  defp page_title(:edit), do: "Edit Book"
end
