defmodule BookifyWeb.BookLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Book
  import Bookify.Utils.Image

  alias Bookify.Books
  alias Bookify.Authors
  alias Bookify.Books.Book
  alias Bookify.Reviews
  alias BookifyWeb.Modules.LiveUploader

  def mount(_params, _session, socket) do
    {:ok,
     socket
      |> assign(:book_modal_action, nil)
      |> assign(:show_review_modal, false)}
  end

  def handle_params(%{"isbn" => isbn}, _url, socket) do
    socket =
      case Books.get_book_by_isbn(isbn, [:author]) do
        book = %Book{} ->
          reviews = Reviews.list_book_reviews(book.id)
          authors =
            Authors.list_authors()
            |> select_options()

          socket
          |> assign(:book, book)
          |> assign(:authors, authors)
          |> assign(:reviews, reviews)
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
      {:noreply, socket |> assign(:book_modal_action, :edit)}
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

  def handle_event("add_review", _params, socket) do
    user = current_user(socket)
    if user do
      {:noreply, assign(socket, :show_review_modal, true)}
    else
      {:noreply, push_navigate(socket, to: ~p"/accounts/login")}
    end
  end

  def handle_event("delete_review", %{"id" => id}, socket) do
    review = Reviews.get_review(id)

    case Reviews.delete_review(review) do
      {:ok, review} ->
        updated_reviews =
          socket.assigns.reviews
          |> Enum.reject(fn r -> r.id == review.id end)

        socket =
          socket
          |> put_flash(:info, "Review deleted successfully")
          |> assign(:reviews, updated_reviews)

        {:noreply, socket}

      {:error, _reason} ->
        socket
        |> put_flash(:error, "Something went wrong")
        |> push_patch(to: socket.assigns.url)

        {:noreply, socket}
    end
  end

  def handle_event("dismiss_book_modal", _params, socket) do
    {:noreply, assign(socket, :book_modal_action, nil)}
  end

  def handle_event("dismiss_review_modal", _params, socket) do
    {:noreply, assign(socket, :book_modal_action, nil)}
  end

  def handle_info({:book_saved, book}, socket) do
    socket =
      socket
      |> assign(:book, book)
      |> assign(:book_modal_action, nil)
      |> put_flash(:info, "Book updated successfully")
      |> stream(:reviews, socket.assigns.streams.reviews)

    {:noreply, socket}
  end

  def handle_info({:review_saved, review}, socket) do
    updated_reviews = [review | socket.assigns.reviews]
    socket =
      socket
      |> assign(:show_review_modal, false)
      |> assign(:reviews, updated_reviews)
      |> put_flash(:info, "Review saved successfully")

    {:noreply, socket}
  end

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not Allowed!")
     |> push_navigate(to: ~p"/")}
  end
end
