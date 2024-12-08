defmodule BookifyWeb.BookListItem do
  use BookifyWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="book-list-item flex w-full transition-all hover:scale-105">
      <.link navigate={~p"/books/#{@book.isbn}"}>
        <img src={@book.cover_image_url} />
      </.link>
    </div>
    """
  end
end
