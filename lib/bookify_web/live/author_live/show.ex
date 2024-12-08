defmodule BookifyWeb.AuthorLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.User

  alias Bookify.Authors

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    author = Authors.get_author(id, [:books])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:author, author)}
  end

  def handle_event("edit_author", _params, socket) do
    author = socket.assigns.author
    {:noreply, push_navigate(socket, to: ~p"/authors/#{author.id}/show/edit")}
  end

  def handle_event("delete_author", _params, socket) do
    author = socket.assigns.author

    socket =
      case Authors.delete_author(author) do
        {:ok, _} ->
          put_flash(socket, :info, "Author deleted successfully")

        {:error, _} ->
          put_flash(socket, :error, "Something went wrong")
      end

    {:noreply, push_navigate(socket, to: ~p"/authors")}
  end

  defp page_title(:show), do: "Show Author"
  defp page_title(:edit), do: "Edit Author"
end
