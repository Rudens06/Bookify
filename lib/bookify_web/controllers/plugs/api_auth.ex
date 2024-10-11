defmodule BookifyWeb.Plugs.ApiAuth do
  import Phoenix.Controller
  import Plug.Conn

  alias Bookify.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    token =
      get_req_header(conn, "Authorization") |> List.first() |> String.trim_leading("Bearer ")

    case Auth.get_user_by_token(token) do
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
