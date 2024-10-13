defmodule BookifyWeb.Plugs.Api.V1.AuthenticateApi do
  import Phoenix.Controller
  import Plug.Conn

  alias Bookify.Users
  alias Bookify.Auth.UserToken

  def init(opts), do: opts

  def call(conn, _opts) do
    token =
      get_req_header(conn, "Authorization")
      |> List.first()
      |> String.trim_leading("Bearer ")
      |> UserToken.decode_token()

    case Users.get_user_by_token(token, :api) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token"})
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end
end
