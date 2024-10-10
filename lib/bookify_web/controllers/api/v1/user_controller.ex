defmodule BookifyWeb.Api.V1.UserController do
  use BookifyWeb, :controller

  alias Bookify.Users
  alias Bookify.Users.User

  action_fallback BookifyWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user_by_public_id!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user_by_public_id!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end
end
