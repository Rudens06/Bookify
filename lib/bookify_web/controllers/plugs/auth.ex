defmodule BookifyWeb.Plugs.Auth do
  use BookifyWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Phoenix.LiveView
  alias Bookify.Users
  alias Bookify.Users.User

  def log_in_user(conn, user) do
    Users.invalidate_tokens(user, :session)
    {token, _user_token} = Users.generate_token(user.id, :session)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> redirect(to: user_return_to || authenticated_path())
  end

  def log_out_user(conn) do
    token = get_session(conn, :user_token)
    live_socket_id = get_session(conn, :live_socket_id)

    token && Users.invalidate_token(token, :session)
    live_socket_id && terminate_live_view_sessions(live_socket_id)

    conn
    |> renew_session()
    |> redirect(to: authenticated_path())
  end

  def put_current_user(conn, _opts) do
    token = get_session(conn, :user_token)
    user = token && Users.get_user_by_token(token, :session)
    assign(conn, :current_user, user)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You should be logged in to access this page!")
      |> put_return_to()
      |> redirect(to: login_path())
      |> halt()
    end
  end

  def redirect_if_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: authenticated_path())
      |> halt()
    else
      conn
    end
  end

  def on_mount(:redirect_if_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, LiveView.redirect(socket, to: authenticated_path())}
    else
      {:cont, socket}
    end
  end

  def on_mount(:require_authenticated_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, LiveView.redirect(socket, to: login_path())}
    end
  end

  def user_is_admin?(nil), do: false

  def user_is_admin?(user) do
    User.admin_role() in user.roles
  end

  defp mount_current_user(socket, session) do
    if token = session["user_token"] do
      user = Users.get_user_by_token(token, :session)
      Phoenix.Component.assign(socket, :current_user, user)
    else
      Phoenix.Component.assign(socket, :current_user, nil)
    end
  end

  defp terminate_live_view_sessions(live_socket_id) do
    BookifyWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_return_to(%{method: "GET"} = conn) do
    conn
    |> put_session(:user_return_to, current_path(conn))
  end

  defp put_return_to(conn), do: conn

  defp authenticated_path(), do: ~p"/"
  defp login_path(), do: ~p"/accounts/login"
end
