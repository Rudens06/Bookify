defmodule BookifyWeb.Api.V1.ListController do
  use BookifyWeb, :controller

  import Bookify.Utils.User

  alias Bookify.Lists
  alias Bookify.Lists.List
  alias Bookify.Users

  action_fallback BookifyWeb.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    current_user = current_user(conn)
    user = Users.get_user_by_public_id!(user_id)

    if user.public or user.id == current_user.id do
      lists = Lists.lists_by_user_id(user.id)

      render(conn, :index, lists: lists)
    else
      {:error, {:forbidden, "User is private!"}}
    end
  end

  def create(conn, %{"list" => list_params}) do
    with {:ok, %List{} = list} <- Lists.create_list(current_user(conn), list_params) do
      conn
      |> put_status(:created)
      |> render(:show, list: list)
    end
  end

  def show(conn, %{"id" => id}) do
    list = Lists.get_list!(id)
    render(conn, :show, list: list)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    current_user_id = current_user(conn).id

    case Lists.get_list!(id) do
      %List{user_id: ^current_user_id} = list ->
        with {:ok, %List{} = updated_list} <- Lists.update_list(list, list_params) do
          render(conn, :show, list: updated_list)
        end

      _ ->
        nil
    end
  end

  def delete(conn, %{"id" => id}) do
    list = Lists.get_list!(id)
    current_user = current_user(conn)

    if list.user_id == current_user.id do
      with {:ok, %List{}} <- Lists.delete_list(list) do
        send_resp(conn, :no_content, "")
      end
    else
      {:error, {:not_found, "List not found"}}
    end
  end
end
