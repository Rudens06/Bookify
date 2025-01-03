defmodule BookifyWeb.Api.V1.UserController do
  use BookifyWeb, :controller

  import Bookify.Utils.User

  alias Bookify.Users
  alias Bookify.Users.User

  action_fallback BookifyWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    case Users.get_user_by_public_id(id) do
      %User{} = user ->
        render(conn, :show, user: user)

      error ->
        error
    end
  end

  def current(conn, _params) do
    user = current_user(conn)
    render(conn, :show, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = current_user(conn)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end
end
