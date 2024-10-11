defmodule BookifyWeb.AccountLive.Register do
  use BookifyWeb, :live_view

  alias Bookify.Users.User
  alias Bookify.Users

  def mount(_params, _session, socket) do
    changeset = User.registration_changeset()

    socket = assign(socket, :form, to_form(changeset))

    {:ok, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.create_user(user_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, "User registered successfully!")
          |> push_redirect(to: ~p"/")

        {:noreply, socket}
    end
  end
end
