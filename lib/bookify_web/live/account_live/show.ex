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

    {:noreply, stream_insert(socket, :api_tokens, user_token, at: 0)}
  end

  def handle_event("delete_all_tokens", _params, socket) do
    Users.invalidate_tokens(current_user(socket), :api)
    {:noreply, stream(socket, :api_tokens, [], reset: true)}
  end

  def handle_event("delete_token", %{"id" => id}, socket) do
    token_id = String.to_integer(id)
    user_token = Users.get_token_by_id(current_user(socket), token_id)
    Users.invalidate_token(user_token.token)
    {:noreply, stream_delete(socket, :api_tokens, user_token)}
  end
end