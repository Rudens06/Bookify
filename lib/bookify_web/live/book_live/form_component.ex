defmodule BookifyWeb.BookLive.FormComponent do
  use BookifyWeb, :live_component
  alias Bookify.Books
  alias BookifyWeb.Modules.LiveUploader

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
          <div phx-drop-target={@uploads.cover_image.ref}>
            <div class="mb-2 text-sm font-semibold">Cover Image</div>
            <.live_file_input upload={@uploads.cover_image} />
          </div>
          <%= for entry <- @uploads.cover_image.entries do %>
            <.live_img_preview entry={entry} class="w-48" />
          <% end %>
          <%= for {_ref, msg} <- @uploads.cover_image.errors do %>
            <div class="text-red-500 text-lg font-bold">
              <%= Phoenix.Naming.humanize(msg) <> "!" %>
            </div>
          <% end %>

          <.input field={@form[:cover_image_filename]} type="hidden" />
          <.input field={@form[:cover_image_url]} type="text" label="Cover Image url" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Book</.button>
          </:actions>
        </.simple_form>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:cover_image,
       accept: ~w(.jpg .jpeg .png),
       max_file_size: 5_000_000,
       max_entries: 1
     )}
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
    book_params =
      book_params
      |> handle_upload(socket)
      |> transform_genres()

    save_book(socket, socket.assigns.action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, book} ->
        book = Books.preload(book, [:author])
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Books.create_book(book_params) do
      {:ok, book} ->
        book = Books.preload(book, [:author])
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_upload(book_params, socket) do
    uploaded_files = LiveUploader.handle_upload(socket, :cover_image)

    case uploaded_files do
      [filename | _] -> Map.put(book_params, "cover_image_filename", filename)
      _ -> book_params
    end
  end

  defp notify_parent(msg), do: send(self(), msg)

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
