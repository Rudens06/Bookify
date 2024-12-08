defmodule BookifyWeb.UserLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.DateTime
  alias Bookify.Lists
  alias Bookify.Users
  alias Bookify.Users.User

  def mount(%{"public_id" => public_id}, _session, socket) do
    socket =
      case Users.get_user_by_public_id(public_id) do
        user = %User{} ->
          lists = Lists.lists_by_user_id(user.id)

          socket
          |> assign(:lists, lists)
          |> assign(:user, user)
          |> assign(:page_title, "#{user.name} Profile")

        {:error, {:not_found, message}} ->
          socket
          |> put_flash(:error, message)
          |> push_navigate(to: ~p"/users")
      end

    {:ok, socket}
  end
end
