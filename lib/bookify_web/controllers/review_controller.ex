defmodule BookifyWeb.ReviewController do
  use BookifyWeb, :controller

  import BookifyWeb.Helpers.User
  import BookifyWeb.Plugs.RequireAdmin
  import Ecto.Changeset

  alias Bookify.Review
  alias Bookify.Reviews
  alias Bookify.Book
  alias Bookify.Books

  plug BookifyWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_review_owner when action in [:update, :edit, :delete]

  def create(conn, %{"review" => review_params, "book_id" => book_id}) do
    book = Books.get_by_id!(book_id)

    review_changeset =
      Review.new()
      |> Review.changeset(review_params)
      |> change(approved: false)
      |> put_assoc(:user, current_user(conn))
      |> put_assoc(:book, book)

    case Reviews.insert(review_changeset) do
      {:ok, _review} ->
        Books.update_avg_rating(book_id)

        conn
        |> put_flash(:info, gettext("Review submitted for approval!"))
        |> redirect(to: Routes.book_path(conn, :show, Book.slug_with_id(book)))

      {:error, review_changeset} ->
        conn
        |> put_flash(:error, gettext("Error occured"))
        |> put_view(BookifyWeb.BookHTML)
        |> assign(:book, book)
        |> assign(:review_changeset, review_changeset)
        |> render(:show)
    end
  end

  def index(conn, _params) do
    render(conn, :index)
  end

  def delete(conn, %{"review_id" => review_id, "book_id" => book_id}) do
    Reviews.delete_review_by_id!(review_id)
    book = Books.get_by_id!(book_id)

    conn
    |> put_flash(:info, gettext("Deleted Successfully"))
    |> redirect(to: Routes.book_path(conn, :show, Book.slug_with_id(book)))
  end

  def delete(conn, %{"review_id" => review_id}) do
    Reviews.delete_review_by_id!(review_id)

    conn
    |> put_flash(:info, gettext("Deleted Successfully"))
    |> redirect(to: Routes.admin_path(conn, :reviews))
  end

  def check_review_owner(conn, _params) do
    %{params: %{"review_id" => review_id}} = conn
    review = Reviews.get_by_id!(review_id)

    if review.user_id == current_user(conn).id || user_is_admin?(current_user(conn)) do
      conn
    else
      conn
      |> put_flash(:error, gettext("Not Allowed"))
      |> redirect(to: Routes.book_path(conn, :index))
      |> halt()
    end
  end
end
