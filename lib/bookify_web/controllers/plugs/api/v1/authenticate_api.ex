defmodule BookifyWeb.Plugs.Api.V1.AuthenticateApi do
  import Phoenix.Controller
  import Plug.Conn

  alias Bookify.Users
  alias Bookify.Users.User

  def init(opts), do: opts

  def call(conn, _opts) do
    case extract_token_from_header(conn) do
      nil ->
        conn
        |> error_response("Authorization token not found")

      token ->
        case Users.get_user_by_token(token, :api) do
          nil ->
            conn
            |> error_response("Invalid authorization token")

          user = %User{} ->
            assign(conn, :current_user, user)
        end
    end
  end

  defp error_response(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: message})
    |> halt()
  end

  defp extract_token_from_header(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> case do
      "Bearer " <> token -> String.trim(token)
      _ -> nil
    end
  end
end
