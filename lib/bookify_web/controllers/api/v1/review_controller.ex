defmodule BookifyWeb.Api.V1.ReviewController do
  use BookifyWeb, :controller

  import Bookify.Utils.User

  alias Bookify.Reviews.Review
  alias Bookify.Books.Book
  alias Bookify.Reviews
  alias Bookify.Books

  alias BookifyWeb.Plugs.EnsureReviewOwner

  plug EnsureReviewOwner when action in [:update, :delete]

  action_fallback BookifyWeb.FallbackController

  def index(conn, %{"isbn" => isbn}) do
    case Books.get_book_by_isbn(isbn) do
      %Book{} = book ->
        reviews = Reviews.list_reviews(book_id: book.id)
        render(conn, :index, reviews: reviews)

      error ->
        error
    end
  end

  def create(conn, %{"isbn" => isbn, "review" => review_params}) do
    case Books.get_book_by_isbn(isbn) do
      %Book{} = book ->
        user = current_user(conn)

        with {:ok, %Review{} = review} <-
               Reviews.create_review(book, user, review_params) do
          conn
          |> put_status(:created)
          |> render(:show, review: review)
        end

      error ->
        error
    end
  end

  def show(conn, %{"id" => id}) do
    case Reviews.get_review(id) do
      %Review{} = review ->
        render(conn, :show, review: review)

      error ->
        error
    end
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    case Reviews.get_review(id) do
      %Review{} = review ->
        with {:ok, %Review{} = review} <- Reviews.update_review(review, review_params) do
          render(conn, :show, review: review)
        end

      error ->
        error
    end
  end

  def delete(conn, %{"id" => id}) do
    case Reviews.get_review(id) do
      %Review{} = review ->
        with {:ok, %Review{}} <- Reviews.delete_review(review) do
          send_resp(conn, :no_content, "")
        end

      error ->
        error
    end
  end
end
