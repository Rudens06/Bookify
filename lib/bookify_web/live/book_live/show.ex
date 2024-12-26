defmodule BookifyWeb.BookLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Book
  import Bookify.Utils.Image

  alias Bookify.Books
  alias Bookify.Authors
  alias Bookify.Books.Book
  alias BookifyWeb.Modules.LiveUploader

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:modal_action, nil)}
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
          |> assign(:page_title, book.title)

        {:error, {:not_found, message}} ->
          socket
          |> put_flash(:error, message)
          |> push_navigate(to: ~p"/")
      end

    {:noreply, socket}
  end

  def handle_event("edit_book", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      {:noreply, socket |> assign(:modal_action, :edit)}
    else
      not_allowed(socket)
    end
  end

  def handle_event("delete_book", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      book = socket.assigns.book

      socket =
        case Books.delete_book(book) do
          {:ok, _} ->
            LiveUploader.delete_file(book.cover_image_filename)
            put_flash(socket, :info, "Book deleted successfully")

          {:error, _} ->
            put_flash(socket, :error, "Something went wrong")
        end

      {:noreply, push_navigate(socket, to: ~p"/")}
    else
      not_allowed(socket)
    end
  end

  def handle_event("dismiss_modal", _params, socket) do
    {:noreply, assign(socket, :modal_action, nil)}
  end

  def handle_info({:saved, book}, socket) do
    socket =
      socket
      |> assign(:book, book)
      |> assign(:modal_action, nil)
      |> put_flash(:info, "Book updated successfully")

    {:noreply, socket}
  end

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not Allowed!")
     |> push_navigate(to: ~p"/")}
  end
end
