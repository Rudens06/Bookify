defmodule BookifyWeb.BookImportLive.Index do
  alias Ecto.Changeset
  use BookifyWeb, :live_view
  import Bookify.Utils.Book

  alias Bookify.Books.Book
  alias Bookify.Authors
  alias BookifyWeb.Modules.JanisRoze

  def mount(_params, _session, socket) do
    authors =
      Authors.list_authors()
      |> select_options()

    {:ok,
     socket
     |> assign(authors: authors)
     |> assign(show_modal: false)
     |> assign(books: [])
     |> assign(message: nil)
     |> assign(query: "")
     |> assign(loading: false)
     |> assign(book: %Book{})}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    if String.trim(query) == "" do
      {:noreply, put_flash(socket, :error, "Please enter a search query")}
    else
      parent_pid = self()

      {:ok, task} =
        Task.Supervisor.start_child(Bookify.TaskSupervisor, fn ->
          result = JanisRoze.fetch_search_results(query)
          send(parent_pid, {:search_results_fetched, result})
        end)

      {:noreply, assign(socket, loading: true, show_modal: true, task: task)}
    end
  end

  def handle_event("import_book", %{"url" => url, "image_url" => image_url}, socket) do
    parent_pid = self()

    {:ok, task} =
      Task.Supervisor.start_child(Bookify.TaskSupervisor, fn ->
        result = JanisRoze.fetch_book_details(url, image_url)
        send(parent_pid, {:book_details_fetched, result})
      end)

    {:noreply, assign(socket, show_modal: true, loading: true, task: task)}
  end

  def handle_event("close_modal", _params, socket) do
    if socket.assigns[:task] do
      Task.Supervisor.terminate_child(Bookify.TaskSupervisor, socket.assigns.task)
    end

    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_info({:book_details_fetched, {:ok, book_params}}, socket) do
    changeset = Book.changeset(%Book{}, book_params)

    socket =
      socket
      |> assign(loading: false)
      |> assign(book: changeset |> Changeset.apply_changes())

    {:noreply, socket}
  end

  def handle_info({:book_details_fetched, {:error, _reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, "Something went wrong")
      |> assign(loading: false)
      |> assign(show_modal: false)

    {:noreply, socket}
  end

  def handle_info({:search_results_fetched, {:ok, books}}, socket) do
    if Enum.empty?(books) do
      socket =
        socket
        |> put_flash(:error, "No books found")
        |> assign(books: [])
        |> assign(show_modal: false)
        |> assign(loading: false)

      {:noreply, socket}
    else
      socket =
        socket
        |> assign(books: books)
        |> assign(show_modal: false)
        |> assign(loading: false)

      {:noreply, socket}
    end
  end

  def handle_info({:search_results_fetched, {:error, _reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, "Something went wrong")
      |> assign(loading: false)
      |> assign(show_modal: false)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl rounded-lg border p-10 shadow-lg">
      <h1 class="text-center text-4xl font-semibold">Import Books</h1>
      <div class="search max-w-md mx-auto">
        <form phx-submit="search">
          <.input name="query" value={@query} type="text" placeholder="Search..."></.input>
          <.button phx-disable-with="Searching..." type="submit">Search</.button>
        </form>
        <div if={@message}>
          <h2 class="text-red-500"><%= @message %></h2>
        </div>
      </div>
      <div class="grid mt-2 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        <%= for book <- @books do %>
          <div class="flex flex-col justify-between border rounded-lg shadow-md overflow-hidden h-full">
            <a href={book.link} target="_blank" class="block">
              <img src={book.image_url} alt={book.title} class="w-full h-72 object-cover" />
            </a>
            <div class="p-4 flex flex-col flex-grow">
              <h3 class="mb-2 text-lg font-semibold">
                <%= book.title %>
              </h3>
              <div class="mt-auto flex gap-2">
                <a
                  href={book.link}
                  target="_blank"
                  class="rounded-lg bg-zinc-900 hover:bg-zinc-700 py-3 px-3 text-sm font-semibold text-white"
                >
                  More info
                </a>
                <.button
                  phx-click="import_book"
                  phx-value-url={book.link}
                  phx-value-image_url={book.image_url}
                  class="rounded-lg bg-yellow-500 hover:bg-yellow-800 py-3 px-3 text-sm font-semibold text-white"
                >
                  Import
                </.button>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    <.modal :if={@show_modal} id="book-import-modal" show on_cancel={JS.push("close_modal")}>
      <.live_component
        id="book-import-form-component"
        module={BookifyWeb.BookLive.FormComponent}
        book={@book}
        authors={@authors}
        loading={@loading}
        action={:new}
        patch={~p"/book_import"}
      />
    </.modal>
    """
  end
end
