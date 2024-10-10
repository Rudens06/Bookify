defmodule BookifyWeb.Plugs.EnsureReviewOwner do
  import Plug.Conn
  import Phoenix.Controller
  import Bookify.Utils.User

  alias Bookify.Reviews

  def init(opts), do: opts

  def call(conn, _opts) do
    review_id = conn.params["id"]
    user = current_user(conn)
    review = Reviews.get_review!(review_id)

    if review.user_id == user.id do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "You are not authorized to access this review."})
      |> halt()
    end
  end
end
