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
      <%= if @list.books != [] do %>
        <h2 class="text-2xl font-bold mb-4"><%= String.capitalize(@list.name) %></h2>
        <div class="flex p-2 gap-2 flex-wrap rounded-lg bg-gray-200">
          <%= for book <- @list.books do %>
            <.live_component
              module={BookifyWeb.BookListItem}
              book={book}
              id={@list.name <> Integer.to_string(book.id)}
            />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
