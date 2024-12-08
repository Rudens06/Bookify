defmodule BookifyWeb.UserLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.DateTime
  alias Bookify.Lists

  def mount(%{"public_id" => public_id}, _session, socket) do
    user = Bookify.Users.get_user_by_public_id(public_id)
    lists = Lists.lists_by_user_id(user.id)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:lists, lists)}
  end
end
