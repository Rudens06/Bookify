defmodule BookifyWeb.BookLive.FormComponent do
  use BookifyWeb, :live_component
  alias Bookify.Books

  def render(assigns) do
    ~H"""
    <div>
      <%= if @loading do %>
        <.loader>
          <:loading_text>
            Loading...
          </:loading_text>
        </.loader>
      <% else %>
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
          <.input field={@form[:page_count]} type="number" min="1" label="Page count" />
          <.input field={@form[:publish_year]} type="number" min="1" label="Publish year" />
          <.input field={@form[:cover_image_url]} type="text" label="Cover Image url" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Book</.button>
          </:actions>
        </.simple_form>
      <% end %>
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
    book_params = transform_genres(book_params)

    changeset =
      Books.change_book(socket.assigns.book, book_params)
      |> transform_genres(book_params["genres"])

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    book_params = transform_genres(book_params)
    save_book(socket, socket.assigns.action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> redirect(to: socket.assigns.patch)}

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
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp transform_genres(changeset, genres) do
    Ecto.Changeset.put_change(changeset, :genres, genres_to_string(genres))
  end

  defp transform_genres(book_params) do
    Map.put(book_params, "genres", genres_to_list(book_params["genres"]))
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
