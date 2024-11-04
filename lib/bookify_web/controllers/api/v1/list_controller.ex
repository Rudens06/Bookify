defmodule BookifyWeb.Api.V1.ListController do
  use BookifyWeb, :controller

  import Bookify.Utils.User

  alias Bookify.Lists.ListBook
  alias Bookify.Lists.List
  alias Bookify.Books.Book
  alias Bookify.Users.User
  alias Bookify.Lists
  alias Bookify.Books
  alias Bookify.Users

  alias BookifyWeb.Plugs.EnsureListOwner

  @user_private_message "User is private"

  plug EnsureListOwner when action in [:update, :delete, :add_book, :update_book, :remove_book]

  action_fallback BookifyWeb.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    current_user = current_user(conn)

    case Users.get_user_by_public_id(user_id) do
      %User{} = user ->
        if user.public or user.id == current_user.id do
          lists = Lists.lists_by_user_id(user.id)

          render(conn, :index, lists: lists)
        else
          user_private_error()
        end

      error ->
        error
    end
  end

  def create(conn, %{"list" => list_params}) do
    with {:ok, %List{} = list} <- Lists.create_list(current_user(conn), list_params) do
      conn
      |> put_status(:created)
      |> render(:show, list: list)
    end
  end

  def show(conn, _params) do
    list = conn.assigns.list
    render(conn, :show, list: list)
  end

  def update(conn, %{"list" => list_params}) do
    list = conn.assigns.list

    with {:ok, %List{} = updated_list} <- Lists.update_list(list, list_params) do
      render(conn, :show, list: updated_list)
    end
  end

  def delete(conn, _params) do
    list = conn.assigns.list

    with {:ok, %List{}} <- Lists.delete_list(list) do
      send_resp(conn, :no_content, "")
    end
  end

  def add_book(conn, %{"book_id" => book_id, "list_book" => list_book_params}) do
    case Books.get_book(book_id) do
      %Book{} = book ->
        list = conn.assigns.list

        with {:ok, list_book = %ListBook{}} <- Lists.add_book(list, book, list_book_params) do
          render(conn, :add_book, %{list_book: list_book})
        end

      error ->
        error
    end
  end

  def update_book(conn, %{
        "list_id" => list_id,
        "book_id" => book_id,
        "list_book" => list_book_params
      }) do
    case Lists.get_list_book(list_id, book_id) do
      %ListBook{} = list_book ->
        with {:ok, list_book = %ListBook{}} <- Lists.update_book_list(list_book, list_book_params) do
          render(conn, :update_book, %{list_book: list_book})
        end

      error ->
        error
    end
  end

  def remove_book(conn, %{
        "list_id" => list_id,
        "book_id" => book_id
      }) do
    case Lists.get_list_book(list_id, book_id) do
      %ListBook{} = list_book ->
        with {:ok, %ListBook{}} <- Lists.remove_book(list_book) do
          send_resp(conn, :no_content, "")
        end

      error ->
        error
    end
  end

  defp user_private_error() do
    {:error, {:forbidden, @user_private_message}}
  end
end
