defmodule BookifyWeb.AccountLive.Register do
  use BookifyWeb, :live_view

  alias Bookify.Users.User
  alias Bookify.Users

  def mount(_params, _session, socket) do
    changeset = User.registration_changeset(%User{})

    socket = assign(socket, form: to_form(changeset), trigger_submit: false)

    {:ok, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.create_user(%User{}, user_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:ok, user} ->
        changeset = User.registration_changeset(user)

        socket =
          socket
          |> put_flash(:info, "User registered successfully!")
          |> assign(trigger_submit: true, from: to_form(changeset))

        {:noreply, socket}
    end
  end
end
