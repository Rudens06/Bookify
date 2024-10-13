defmodule BookifyWeb.AccountLive.Show do
  use BookifyWeb, :live_view

  import Bookify.Utils.User
  alias Bookify.Users

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    {:ok, assign(socket, user: user, api_key: nil)}
  end

  def handle_event("gen_api_key", _params, socket) do
    api_key =
      current_user(socket)
      |> Users.generate_new_api_key()

    {:noreply, assign(socket, api_key: api_key)}
  end
end
