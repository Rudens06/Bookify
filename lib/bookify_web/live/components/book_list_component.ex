defmodule BookifyWeb.BookListComponent do
  use BookifyWeb, :live_component
  alias Bookify.Lists

  def update(assigns, socket) do
    list =
      case Lists.get_list_by_name(assigns.list_name, assigns.user.id, books: [:author]) do
        {:error, _} ->
          nil

        list ->
          list
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(list: list)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <h2 class="text-2xl font-bold mb-4"><%= String.capitalize(@list.name) %></h2>
      <div class="grid grid-cols-2 lg:grid-cols-6">
        <%= for book <- @list.books do %>
          <.live_component
            module={BookifyWeb.BookListItem}
            book={book}
            id={@list.name <> Integer.to_string(book.id)}
          />
        <% end %>
      </div>
    </div>
    """
  end
end