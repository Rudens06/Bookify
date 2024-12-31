defmodule BookifyWeb.BookListItem do
  use BookifyWeb, :live_component
  import Bookify.Utils.Image

  def render(assigns) do
    ~H"""
    <div class="book-list-item m-1 flex items-center justify-center w-32 h-48 object-cover overflow-hidden transition-all hover:scale-105">
      <.link navigate={~p"/books/#{@book.isbn}"}>
        <img src={image(@book)} />
      </.link>
    </div>
    """
  end
end
