defmodule BookifyWeb.AuthorLive.Index do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Integer

  alias Bookify.Authors
  alias Bookify.Authors.Author

  def mount(_params, _session, socket) do
    authors = Authors.list_authors()

    {:ok,
     socket
     |> assign(:authors, authors)
     |> assign(:query, "")}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("search", %{"value" => query}, socket) do
    authors =
      if query == "" do
        Authors.list_authors()
      else
        Authors.search_authors(query)
      end

    {:noreply,
     socket
     |> assign(:authors, authors)
     |> assign(:query, query)}
  end

  def handle_event("add_author", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/authors/new")}
  end

  def handle_event("edit_author", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/authors/#{id}/edit")}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case validate_integer_id(id) do
      {:ok, id} ->
        case Authors.get_author(id) do
          author = %Author{} ->
            socket
            |> assign(:page_title, "Edit Author")
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
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Author")
    |> assign(:author, %Author{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Authors")
    |> assign(:author, nil)
  end
end
