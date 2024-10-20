defmodule BookifyWeb.AccountLive.Show do
  use BookifyWeb, :live_view

  import Bookify.Utils.User
  import BookifyWeb.Utils.DateTime
  alias Bookify.Users

  def mount(_params, _session, socket) do
    user = current_user(socket)
    api_tokens = Users.get_users_tokens(user, :api)

    socket =
      socket
      |> assign(user: user, page_title: "Profile")
      |> stream(:api_tokens, api_tokens)

    {:ok, socket}
  end

  def handle_event("gen_token", _params, socket) do
    {_token, user_token} =
      current_user(socket)
      |> Users.generate_new_api_token()

    {:noreply, stream_insert(socket, :api_tokens, user_token, at: -1)}
  end
end
