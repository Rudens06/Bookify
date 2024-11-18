defmodule BookifyWeb.Plugs.EnsureReviewOwner do
  import Plug.Conn
  import Phoenix.Controller
  import Bookify.Utils.User

  alias Bookify.Reviews
  alias Bookify.Reviews.Review

  def init(opts), do: opts

  def call(conn, _opts) do
    review_id = conn.params["id"]
    user = current_user(conn)

    case Reviews.get_review(review_id) do
      %Review{} = review ->
        if review.user_id == user.id do
          conn
        else
          conn
          |> put_status(:forbidden)
          |> json(%{errors: [%{detail: "You are not authorized to access this review."}]})
          |> halt()
        end

      {:error, {:not_found, message}} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: [%{detail: message}]})
        |> halt()
    end
  end
end
