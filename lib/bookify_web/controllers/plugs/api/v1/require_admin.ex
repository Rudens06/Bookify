defmodule BookifyWeb.Plugs.Api.V1.RequireAdmin do
  import Phoenix.Controller
  import Plug.Conn

  alias BookifyWeb.Plugs.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    if Auth.user_is_admin?(conn.assigns.current_user) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not allowed!"})
      |> halt()
    end
  end
end
