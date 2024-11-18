defmodule BookifyWeb.ReviewComponent do
  use BookifyWeb, :live_component
  import Bookify.Utils.User

  alias Bookify.Reviews
  alias Bookify.Reviews.Review

  def update(assigns, socket) do
    reviews = Reviews.list_book_reviews(assigns.book.id)
    review_changeset = Reviews.change_review(%Review{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(reviews: reviews, form: to_form(review_changeset))}
  end

  def handle_event("save_review", %{"review" => review_params}, socket) do
    book = socket.assigns.book
    user = current_user(socket)

    case Reviews.create_review(book, user, review_params) do
      {:ok, _review} ->
        {:noreply, assign(socket, reviews: Reviews.list_book_reviews(book.id, [:user]))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("delete_review", %{"id" => id}, socket) do
    review = Reviews.get_review(id)

    case Reviews.delete_review(review) do
      {:ok, _review} ->
        {:noreply, assign(socket, reviews: Reviews.list_book_reviews(socket.assigns.book.id))}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
