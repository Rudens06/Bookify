defmodule BookifyWeb.BookLive.Index do
  use BookifyWeb, :live_view

  alias Bookify.Books

  def mount(_params, _session, socket) do
    books = Books.list_books([:author])

    {:ok, assign(socket, :books, books)}
  end
end
