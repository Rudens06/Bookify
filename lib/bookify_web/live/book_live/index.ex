defmodule BookifyWeb.BookLive.Index do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Book

  alias Bookify.Books
  alias Bookify.Authors
  alias Bookify.Books.Book

  @page_size 18
  @default_offset 0

  def mount(_params, _session, socket) do
    books = Books.list_books(@page_size, @default_offset, [:author])

    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:page, 1)
     |> assign(:page_title, "Books")
     |> assign(:book, nil)
     |> assign(:modal_action, nil)
     |> stream(:books, books)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", %{"value" => query}, socket) do
    books =
      if query == "" do
        Books.list_books(@page_size, @default_offset, [:author])
      else
        Books.search_books(query, @page_size, @default_offset, [:author])
      end

    {
      :noreply,
      socket
      |> assign(:query, query)
      |> assign(:page, 1)
      |> stream(:books, books, reset: true)
    }
  end

  def handle_event("add_book", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      authors =
        Authors.list_authors()
        |> select_options()

      socket =
        socket
        |> assign(:page_title, "New Book")
        |> assign(:book, %Book{})
        |> assign(:modal_action, :new)
        |> assign(:authors, authors)

      {:noreply, socket}
    else
      not_allowed(socket)
    end
  end

  def handle_event("edit_book", %{"isbn" => isbn}, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      socket =
        case Books.get_book_by_isbn(isbn) do
          book = %Book{} ->
            authors =
              Authors.list_authors()
              |> select_options()

            socket
            |> assign(:page_title, "Edit Book")
            |> assign(:book, book)
            |> assign(:modal_action, :edit)
            |> assign(:authors, authors)

          {:error, {:not_found, message}} ->
            socket
            |> put_flash(:error, message)
            |> push_navigate(to: ~p"/")
        end

      {:noreply, socket}
    else
      not_allowed(socket)
    end
  end

  def handle_event("delete_book", %{"isbn" => isbn}, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      book = Books.get_book_by_isbn(isbn)

      socket =
        case Books.delete_book(book) do
          {:ok, _} ->
            socket
            |> stream_delete(:books, book)
            |> put_flash(:info, "Book deleted successfully")

          {:error, _} ->
            socket
            |> put_flash(:error, "Something went wrong")
        end

      {:noreply, socket}
    else
      not_allowed(socket)
    end
  end

  def handle_event("dismiss_modal", _params, socket) do
    {:noreply, assign(socket, :modal_action, nil)}
  end

  def handle_event("load_more", _params, socket) do
    books =
      if socket.assigns.query == "" do
        Books.list_books(@page_size, socket.assigns.page * @page_size, [:author])
      else
        Books.search_books(
          socket.assigns.query,
          @page_size,
          socket.assigns.page * @page_size,
          [:author]
        )
      end

    {:noreply,
     assign(socket, page: socket.assigns.page + 1)
     |> stream(:books, books, at: -1)}
  end

  def handle_info({:saved, book}, socket) do
    {:noreply,
     socket
     |> assign(:modal_action, nil)
     |> stream_insert(:books, book)}
  end

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not allowed!")
     |> push_navigate(to: ~p"/")}
  end
end
