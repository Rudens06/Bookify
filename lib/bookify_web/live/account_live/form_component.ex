defmodule BookifyWeb.AccountLive.FormComponent do
  use BookifyWeb, :live_component
  alias Bookify.Users

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Edit Profile
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Changes</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(Users.change_user(assigns.current_user)))}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user(socket.assigns.current_user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.update_user(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        notify_parent({:user_updated, user})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), msg)
end
