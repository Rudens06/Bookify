defmodule BookifyWeb.ListActionButtonComponent do
  use BookifyWeb, :live_component
  alias Bookify.Lists
  alias Bookify.Books

  def update(assigns, socket) do
    user = assigns.current_user

    list =
      case Lists.get_list_by_name(assigns.list_name, user.id, [:books]) do
        {:error, _} ->
          case Lists.create_list(user, %{name: assigns.list_name}) do
            {:ok, list} ->
              list

            {:error, _} ->
              throw("Could not create list")
          end

        list ->
          list
      end

    book_in_list? = Lists.has_book?(list, assigns.book.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(book_in_list?: book_in_list?)
     |> assign(favorites: list)}
  end

  def handle_event("toggle_item", %{"book_id" => book_id}, socket) do
    book = Books.get_book!(book_id)
    list = socket.assigns.favorites
    book_in_list? = socket.assigns.book_in_list?

    if not book_in_list? do
      Lists.add_book(list, book)
    else
      list_book = Lists.get_list_book(list.id, book.id)
      Lists.remove_book(list_book)
    end

    book_in_list? = not book_in_list?

    {:noreply, socket |> assign(book_in_list?: book_in_list?)}
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
end
