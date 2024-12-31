defmodule BookifyWeb.UserSessionController do
  use BookifyWeb, :controller

  alias Bookify.Users
  alias BookifyWeb.Plugs.Auth

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    if user = Users.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Logged in successfully!")
      |> Auth.log_in_user(user)
    else
      conn
      |> put_flash(:error, "Wrong email or password")
      |> redirect(to: ~p"/accounts/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully!")
    |> Auth.log_out_user()
  end
end
