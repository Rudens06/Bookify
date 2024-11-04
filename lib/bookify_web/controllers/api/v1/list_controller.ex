defmodule BookifyWeb.Api.V1.ListController do
  use BookifyWeb, :controller

  import Bookify.Utils.User

  alias Bookify.Lists.ListsBooks
  alias Bookify.Lists
  alias Bookify.Lists.List
  alias Bookify.Books
  alias Bookify.Users
  alias BookifyWeb.Plugs.EnsureListOwner

  plug EnsureListOwner when action in [:update, :delete, :add_book, :update_book, :remove_book]

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

  def show(conn, %{"list_id" => id}) do
    list = Lists.get_list!(id)
    render(conn, :show, list: list)
  end

  def update(conn, %{"list_id" => id, "list" => list_params}) do
    current_user_id = current_user(conn).id

    case Lists.get_list!(id) do
      %List{user_id: ^current_user_id} = list ->
        with {:ok, %List{} = updated_list} <- Lists.update_list(list, list_params) do
          render(conn, :show, list: updated_list)
        end

      _ ->
        {:error, {:not_found, "List not found"}}
    end
  end

  def delete(conn, %{"list_id" => id}) do
    list = Lists.get_list!(id)

    with {:ok, %List{}} <- Lists.delete_list(list) do
      send_resp(conn, :no_content, "")
    end
  end

  def add_book(conn, %{"book_id" => book_id, "list_book" => list_book}) do
    book = Books.get_book!(book_id)
    list = conn.assigns.list

    with {:ok, list_book = %ListsBooks{}} <- Lists.add_book(list, book, list_book) do
      render(conn, :add_book, %{list_book: list_book})
    end
  end

  def update_book(conn, %{
        "list_id" => list_id,
        "book_id" => book_id,
        "list_book" => list_book_params
      }) do
    list_book = Lists.get_list_book(list_id, book_id)

    with {:ok, list_book = %ListsBooks{}} <- Lists.update_book_list(list_book, list_book_params) do
      render(conn, :update_book, %{list_book: list_book})
    end
  end

  def remove_book(conn, %{
        "list_id" => list_id,
        "book_id" => book_id
      }) do
    list_book = Lists.get_list_book(list_id, book_id)

    with {:ok, %ListsBooks{}} <- Lists.remove_book(list_book) do
      send_resp(conn, :no_content, "")
    end
  end
end
