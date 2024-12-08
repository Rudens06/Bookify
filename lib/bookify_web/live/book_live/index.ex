defmodule BookifyWeb.BookLive.Index do
  use BookifyWeb, :live_view
  alias Bookify.Books

  def mount(_params, _session, socket) do
    books = Books.list_books([:author])

    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:books, books)}
  end

  def handle_event("search", %{"value" => query}, socket) do
    books =
      if query == "" do
        Books.list_books([:author])
      else
        Books.search_books(query, [:author])
      end

    {
      :noreply,
      socket
      |> assign(:query, query)
      |> assign(:books, books)
    }
  end
end
