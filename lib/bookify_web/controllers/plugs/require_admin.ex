defmodule BookifyWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller
  import BookifyWeb.Helpers.User
  import BookifyWeb.Gettext

  alias BookifyWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if user_is_admin?(current_user(conn)) do
      conn
    else
      conn
      |> put_flash(:error, gettext("Not Allowed"))
      |> redirect(to: Helpers.book_path(conn, :index))
      |> halt()
    end
  end

  def user_is_admin?(nil), do: false

  def user_is_admin?(user) do
    "admin" in user.roles
  end
end
