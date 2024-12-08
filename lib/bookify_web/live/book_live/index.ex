defmodule BookifyWeb.BookLive.Index do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Book

  alias Bookify.Books
  alias Bookify.Authors
  alias Bookify.Books.Book

  def mount(_params, _session, socket) do
    books = Books.list_books([:author])

    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:books, books)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("search", %{"value" => query}, socket) do
    books =
      if query == "" do
        Books.list_books([:author])
      else
        Books.search_books(query, [:author])
      end

    {
      :noreply,
      socket
      |> assign(:query, query)
      |> assign(:books, books)
    }
  end

  def handle_event("add_book", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/books/new")}
  end

  def handle_event("edit_book", %{"isbn" => isbn}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/books/#{isbn}/edit")}
  end

  defp apply_action(socket, :edit, %{"isbn" => isbn}) do
    case Books.get_book_by_isbn(isbn) do
      book = %Book{} ->
        authors =
          Authors.list_authors()
          |> select_options()

        socket
        |> assign(:page_title, "Edit Book")
        |> assign(:book, book)
        |> assign(:authors, authors)

      {:error, {:not_found, message}} ->
        socket
        |> put_flash(:error, message)
        |> push_navigate(to: ~p"/")
    end
  end

  defp apply_action(socket, :new, _params) do
    authors =
      Authors.list_authors()
      |> select_options()

    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
    |> assign(:authors, authors)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Books")
    |> assign(:book, nil)
  end
end
