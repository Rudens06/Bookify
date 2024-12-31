defmodule BookifyWeb.AuthorLive.FormComponent do
  use BookifyWeb, :live_component
  import Bookify.Utils.Image
  import Bookify.Utils.User

  alias Bookify.Authors
  alias BookifyWeb.Modules.LiveUploader

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= if @action == :edit do %>
          Editing: <%= @author.name %>
        <% else %>
          New Author
        <% end %>
      </.header>

      <.simple_form
        for={@form}
        id="author-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:birth_year]} type="number" label="Birth year" />
        <.input field={@form[:biography]} type="textarea" label="Bio" />
        <.input field={@form[:image_url]} type="text" label="Image url" />
        <div phx-drop-target={@uploads.author_image.ref}>
          <div class="mb-2 text-sm font-semibold">Author Image</div>
          <.live_file_input upload={@uploads.author_image} />
        </div>
        <%= if @uploads.author_image.entries == [] do %>
          <img src={image(@author)} class="w-48" />
        <% else %>
          <%= for entry <- @uploads.author_image.entries do %>
            <.live_img_preview entry={entry} class="w-48" />
          <% end %>
          <%= for {_ref, msg} <- @uploads.author_image.errors do %>
            <div class="text-red-500 text-lg font-bold">
              <%= Phoenix.Naming.humanize(msg) <> "!" %>
            </div>
          <% end %>
        <% end %>
        <.input field={@form[:wikipedia_url]} type="text" label="Wikipedia url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Author</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:author_image,
       accept: ~w(.jpg .jpeg .png),
       max_file_size: 5_000_000,
       max_entries: 1
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:old_filename, assigns.author.image_filename)
     |> assign(:form, to_form(Authors.change_author(assigns.author)))}
  end

  def handle_event("validate", %{"author" => author_params}, socket) do
    changeset = Authors.change_author(socket.assigns.author, author_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    if current_user(socket) |> is_admin?() do
      author_params = handle_upload(author_params, socket)
      save_author(socket, socket.assigns.action, author_params)
    else
      not_allowed(socket)
    end
  end

  defp save_author(socket, :edit, author_params) do
    upload_entries = socket.assigns.uploads.author_image.entries

    case Authors.update_author(socket.assigns.author, author_params) do
      {:ok, author} ->
        if upload_entries != [] do
          LiveUploader.delete_file(socket.assigns.old_filename)
        end

        notify_parent({:author_saved, author})

        {:noreply,
         socket
         |> put_flash(:info, "Author updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_author(socket, :new, author_params) do
    case Authors.create_author(author_params) do
      {:ok, author} ->
        notify_parent({:author_saved, author})

        {:noreply,
         socket
         |> put_flash(:info, "Author created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp handle_upload(book_params, socket) do
    uploaded_files = LiveUploader.handle_upload(socket, :author_image)

    case uploaded_files do
      [filename | _] -> Map.put(book_params, "image_filename", filename)
      _ -> book_params
    end
  end

  defp notify_parent(msg), do: send(self(), msg)

  defp not_allowed(socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Not allowed!")
     |> push_navigate(to: ~p"/")}
  end
end
