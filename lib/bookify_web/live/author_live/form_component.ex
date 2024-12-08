defmodule BookifyWeb.AuthorLive.FormComponent do
  use BookifyWeb, :live_component
  alias Bookify.Authors

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
        <.input field={@form[:wikipedia_url]} type="text" label="Wikipedia url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Author</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Authors.change_author(assigns.author)))}
  end

  def handle_event("validate", %{"author" => author_params}, socket) do
    changeset = Authors.change_author(socket.assigns.author, author_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    save_author(socket, socket.assigns.action, author_params)
  end

  defp save_author(socket, :edit, author_params) do
    case Authors.update_author(socket.assigns.author, author_params) do
      {:ok, _author} ->
        {:noreply,
         socket
         |> put_flash(:info, "Author updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_author(socket, :new, author_params) do
    case Authors.create_author(author_params) do
      {:ok, _author} ->
        {:noreply,
         socket
         |> put_flash(:info, "Author created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
