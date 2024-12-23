defmodule BookifyWeb.AuthorLive.Index do
  use BookifyWeb, :live_view
  import Bookify.Utils.User
  import Bookify.Utils.Integer

  alias Bookify.Authors
  alias Bookify.Authors.Author

  @page_size 18
  @default_offset 0

  def mount(_params, _session, socket) do
    authors = Authors.list_authors(@page_size, @default_offset)

    {:ok,
     socket
     |> stream(:authors, authors)
     |> assign(:query, "")
     |> assign(:page_title, "Authors")
     |> assign(:author, nil)
     |> assign(:modal_action, nil)
     |> assign(:page, 1)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", %{"value" => query}, socket) do
    authors =
      if query == "" do
        Authors.list_authors(@page_size, @default_offset)
      else
        Authors.search_authors(query, @page_size, @default_offset)
      end

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:query, query)
     |> stream(:authors, authors, reset: true)}
  end

  def handle_event("add_author", _params, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      socket =
        socket
        |> assign(:page_title, "New Author")
        |> assign(:author, %Author{})
        |> assign(:modal_action, :new)

      {:noreply, socket}
    else
      not_allowed(socket)
    end
  end

  def handle_event("edit_author", %{"id" => id}, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      socket =
        case validate_integer_id(id) do
          {:ok, id} ->
            case Authors.get_author(id) do
              author = %Author{} ->
                socket
                |> assign(:page_title, "Edit Author")
                |> assign(:author, author)
                |> assign(:modal_action, :edit)

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
    else
      not_allowed(socket)
    end
  end

  def handle_event("delete_author", %{"id" => id}, socket) do
    user = current_user(socket)

    if is_admin?(user) do
      author = Authors.get_author(id)

      socket =
        case Authors.delete_author(author) do
          {:ok, _} ->
            socket
            |> stream_delete(:authors, author)
            |> put_flash(:info, "Author deleted successfully")

          {:error, _} ->
            socket
            |> put_flash(:error, "Something went wrong")
        end

      {:noreply, socket}
    else
      not_allowed(socket)
    end
  end

  def handle_event("load_more", _params, socket) do
    authors =
      if socket.assigns.query == "" do
        Authors.list_authors(@page_size, socket.assigns.page * @page_size)
      else
        Authors.search_authors(
          socket.assigns.query,
          @page_size,
          socket.assigns.page * @page_size
        )
      end

    {:noreply,
     assign(socket, page: socket.assigns.page + 1)
     |> stream(:authors, authors, at: -1)}
  end

  def handle_event("dismiss_modal", _params, socket) do
    {:noreply, assign(socket, :modal_action, nil)}
  end

  def handle_info({:saved, author}, socket) do
    {:noreply,
     socket
     |> assign(:modal_action, nil)
     |> stream_insert(:authors, author)}
  end

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not allowed!")
     |> push_navigate(to: ~p"/authors")}
  end
end
