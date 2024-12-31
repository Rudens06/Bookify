defmodule BookifyWeb.AccountLive.Show do
  use BookifyWeb, :live_view

  import Bookify.Utils.User
  import Bookify.Utils.DateTime
  alias Bookify.Users
  alias Bookify.Lists

  def mount(_params, _session, socket) do
    user = current_user(socket)
    api_tokens = Users.get_users_tokens(user, :api)
    lists = Lists.lists_by_user_id(user.id)

    socket =
      socket
      |> assign(:page_title, "Profile")
      |> assign(:lists, lists)
      |> assign(:show_user_modal, false)
      |> stream(:api_tokens, api_tokens)

    {:ok, socket}
  end

  def handle_event("toggle_profile_visibility", _params, socket) do
    user = current_user(socket)
    new_state = !user.public

    case Users.update_user(user, %{public: new_state}) do
      {:ok, updated_user} ->
        {:noreply, assign(socket, :current_user, updated_user)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update profile visibility.")}
    end
  end

  def handle_event("edit_profile", _params, socket) do
    {:noreply, assign(socket, show_user_modal: true)}
  end

  def handle_event("gen_token", _params, socket) do
    {_token, user_token} =
      current_user(socket)
      |> Users.generate_new_api_token()

    {:noreply,
    socket
    |> put_flash(:info, "New API token generated.")
    |> stream_insert(:api_tokens, user_token, at: 0)}
  end

  def handle_event("delete_all_tokens", _params, socket) do
    Users.invalidate_tokens(current_user(socket), :api)
    {:noreply,
    socket
    |> put_flash(:info, "All API tokens deleted.")
    |> stream(:api_tokens, [], reset: true)}
  end

  def handle_event("delete_token", %{"id" => id}, socket) do
    token_id = String.to_integer(id)
    user_token = Users.get_token_by_id(current_user(socket), token_id)
    Users.invalidate_token(user_token.token)
    {:noreply,
    socket
    |> put_flash(:info, "API token deleted.")
    |> stream_delete(:api_tokens, user_token)}
  end

  def handle_event("dismiss_modal", _params, socket) do
    {:noreply, assign(socket, show_user_modal: false)}
  end

  def handle_info({:user_updated, user}, socket) do
    {:noreply,
    socket
    |> put_flash(:info, "Profile updated successfully!")
    |> assign(:show_user_modal, false)
    |> assign(:current_user, user)}
  end
end
