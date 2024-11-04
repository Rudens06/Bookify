defmodule BookifyWeb.AccountLive.Login do
  use BookifyWeb, :live_view

  alias Bookify.Users.User
  alias Bookify.Users

  def mount(_params, _session, socket) do
    changeset = User.login_changeset(%User{})

    socket = assign(socket, form: to_form(changeset), trigger_submit: false)

    {:ok, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    %{"email" => email, "password" => password} =
      user_params

    changeset =
      User.login_changeset(%User{}, user_params)
      |> Map.put(:action, :validate)

    socket =
      if changeset.valid? do
        user = Users.get_user_by_email_and_password(email, password)

        if user do
          assign(socket, trigger_submit: true)
        else
          socket
          |> put_flash(:error, "Wrong email or password!")
        end
      else
        socket
      end

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
