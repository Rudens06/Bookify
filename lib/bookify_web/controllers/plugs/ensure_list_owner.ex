defmodule BookifyWeb.Plugs.EnsureListOwner do
  import Plug.Conn
  import Phoenix.Controller
  import Bookify.Utils.User

  alias Bookify.Lists
  alias Bookify.Lists.List

  def init(opts), do: opts

  def call(conn, _opts) do
    list_id = conn.params["list_id"]
    user = current_user(conn)

    case Lists.get_list(list_id) do
      %List{} = list ->
        if list.user_id == user.id do
          assign(conn, :list, list)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "You are not authorized to access this list."})
          |> halt()
        end

      error ->
        error
    end
  end
end
