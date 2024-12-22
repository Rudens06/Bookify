defmodule BookifyWeb.BookListItem do
  use BookifyWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="book-list-item flex items-center justify-center w-32 h-48 overflow-hidden transition-all hover:scale-105">
      <.link navigate={~p"/books/#{@book.isbn}"}>
        <img src={@book.cover_image_url} />
      </.link>
    </div>
    """
  end
end
