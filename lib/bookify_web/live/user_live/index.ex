defmodule BookifyWeb.UserLive.Index do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  alias Bookify.Users

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:users, [])
     |> assign(:query, "")}
  end

  def handle_event("search", %{"value" => query}, socket) do
    users =
      if query != "" do
        Users.search_users(query, current_user(socket).id)
      else
        []
      end

    {:noreply,
     socket
     |> assign(:users, users)
     |> assign(:query, query)}
  end
end
