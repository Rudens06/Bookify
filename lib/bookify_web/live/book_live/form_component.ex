defmodule BookifyWeb.BookLive.FormComponent do
  use BookifyWeb, :live_component
  alias Bookify.Books

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= if @action == :edit do %>
          Editing: <%= @book.title %>
        <% else %>
          New Book
        <% end %>
      </.header>

      <.simple_form
        for={@form}
        id="book-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:isbn]} type="text" label="ISBN" />
        <.input
          type="select"
          field={@form[:author_id]}
          label="Author"
          prompt="Select an author"
          options={@authors}
        />
        <.input
          field={@form[:genres]}
          type="text"
          label="Genres"
          placeholder="Example: Fiction, Fantasy, Adventure"
        />
        <.input field={@form[:anotation]} type="textarea" label="Anotation" />
        <.input field={@form[:cover_image_url]} type="text" label="Cover Image url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Book</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    book =
      assigns.book
      |> Map.update!(:genres, &genres_to_string/1)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Books.change_book(book)))}
  end

  def handle_event("validate", %{"book" => book_params}, socket) do
    book_params = Map.put(book_params, "genres", genres_to_list(book_params["genres"]))
    changeset = Books.change_book(socket.assigns.book, book_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    book_params = Map.put(book_params, "genres", genres_to_list(book_params["genres"]))
    save_book(socket, socket.assigns.action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Books.create_book(book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp genres_to_list(""), do: []

  defp genres_to_list(genres) do
    genres
    |> String.split(",")
    |> Enum.uniq()
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn genre ->
      String.trim(genre)
      |> String.downcase()
    end)
  end

  defp genres_to_string([]), do: ""

  defp genres_to_string(genres) do
    genres
    |> Enum.join(", ")
  end
end
