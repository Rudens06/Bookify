defmodule BookifyWeb.Api.V1.AuthorController do
  use BookifyWeb, :controller

  alias Bookify.Authors
  alias Bookify.Authors.Author

  action_fallback BookifyWeb.FallbackController

  def index(conn, _params) do
    authors = Authors.list_authors()
    render(conn, :index, authors: authors)
  end

  def create(conn, %{"author" => author_params}) do
    with {:ok, %Author{} = author} <- Authors.create_author(author_params) do
      conn
      |> put_status(:created)
      |> render(:show, author: author)
    end
  end

  def show(conn, %{"id" => id}) do
    author = Authors.get_author!(id)
    render(conn, :show, author: author)
  end

  def update(conn, %{"id" => id, "author" => author_params}) do
    author = Authors.get_author!(id)

    with {:ok, %Author{} = author} <- Authors.update_author(author, author_params) do
      render(conn, :show, author: author)
    end
  end

  def delete(conn, %{"id" => id}) do
    author = Authors.get_author!(id)

    with {:ok, %Author{}} <- Authors.delete_author(author) do
      send_resp(conn, :no_content, "")
    end
  end
end
