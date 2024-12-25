defmodule BookifyWeb.AuthorLive.Show do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Integer
  import Bookify.Utils.Image

  alias Bookify.Authors
  alias Bookify.Authors.Author

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:modal_action, nil)}
  end

  def handle_params(%{"id" => id}, _, socket) do
    socket =
      case validate_integer_id(id) do
        {:ok, id} ->
          case Authors.get_author(id, [:books]) do
            author = %Author{} ->
              socket
              |> assign(:page_title, author.name)
              |> assign(:author, author)

            {:error, {:not_found, message}} ->
              socket
              |> put_flash(:error, message)
              |> push_navigate(to: ~p"/authors")
          end

        {:error, _} ->
          socket
          |> put_flash(:error, "Author not found")
          |> push_navigate(to: ~p"/authors")
      end

    {:noreply, socket}
  end

  def handle_event("edit_author", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      {:noreply, socket |> assign(:modal_action, :edit)}
    else
      not_allowed(socket)
    end
  end

  def handle_event("delete_author", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      author = socket.assigns.author

      socket =
        case Authors.delete_author(author) do
          {:ok, _} ->
            put_flash(socket, :info, "Author deleted successfully")

          {:error, _} ->
            put_flash(socket, :error, "Something went wrong")
        end

      {:noreply, push_navigate(socket, to: ~p"/authors")}
    else
      not_allowed(socket)
    end
  end

  def handle_event("dismiss_modal", _params, socket) do
    {:noreply, assign(socket, :modal_action, nil)}
  end

  def handle_info({:saved, author}, socket) do
    socket =
      socket
      |> assign(:author, author)
      |> assign(:modal_action, nil)
      |> put_flash(:info, "Author updated successfully")

    {:noreply, socket}
  end

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not Allowed!")
     |> push_navigate(to: ~p"/authors")}
  end
end
