defmodule BookifyWeb.ListActionButtonComponent do
  import Bookify.Utils.User
  use BookifyWeb, :live_component
  alias Bookify.Lists
  alias Bookify.Books

  def update(assigns, socket) do
    user = assigns.current_user

    list =
      if user do
        case Lists.get_list_by_name(assigns.list_name, user.id, [:books]) do
          {:error, _} ->
            nil

          list ->
            list
        end
      else
        nil
      end

    book_in_list? =
      if user do
        case list do
          nil ->
            false

          list ->
            Lists.has_book?(list, assigns.book.id)
        end
      else
        false
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(book_in_list?: book_in_list?)
     |> assign(list: list)}
  end

  def handle_event("toggle_item", %{"book_id" => book_id}, socket) do
    user = current_user(socket)

    if user do
      book = Books.get_book!(book_id)
      list = list(socket.assigns.list_name, user)
      book_in_list? = socket.assigns.book_in_list?

      if not book_in_list? do
        Lists.add_book(list, book)
      else
        list_book = Lists.get_list_book(list.id, book.id)
        Lists.remove_book(list_book)
      end

      book_in_list? = not book_in_list?
      {:noreply, assign(socket, book_in_list?: book_in_list?)}
    else
      {:noreply,
        socket
        |> put_flash(:error, "You must be logged in to add books to your lists")
        |> redirect(to: ~p"/accounts/login")}
    end
  end

  def render(assigns) do
    ~H"""
    <button phx-target={@myself} phx-click="toggle_item" phx-value-book_id={@book.id} class="text-2xl">
      <%= if @book_in_list? do %>
        <%= render_slot(@in_list_icon) %>
      <% else %>
        <%= render_slot(@not_in_list_icon) %>
      <% end %>
    </button>
    """
  end

  defp list(list_name, user) do
    case Lists.get_list_by_name(list_name, user.id, [:books]) do
      {:error, _} ->
        create_list(list_name, user)

      list ->
        list
    end
  end

  defp create_list(list_name, user) do
    case Lists.create_list(user, %{name: list_name}) do
      {:ok, list} ->
        list

      {:error, _} ->
        throw("Could not create list")
    end
  end
end
