defmodule BookifyWeb.Api.V1.AuthorController do
  use BookifyWeb, :controller

  alias Bookify.Authors
  alias Bookify.Authors.Author

  action_fallback BookifyWeb.FallbackController

  @default_limit "50"
  @default_offset "0"
  @max_limit "100"

  def index(conn, params) do
    limit = limit(params)
    offset = offset(params)

    authors = Authors.list_authors(limit, offset)
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
    case Authors.get_author(id) do
      %Author{} = author ->
        render(conn, :show, author: author)

      error ->
        error
    end
  end

  def update(conn, %{"id" => id, "author" => author_params}) do
    case Authors.get_author(id) do
      %Author{} = author ->
        with {:ok, %Author{} = author} <- Authors.update_author(author, author_params) do
          render(conn, :show, author: author)
        end

      error ->
        error
    end
  end

  def delete(conn, %{"id" => id}) do
    case Authors.get_author(id) do
      %Author{} = author ->
        with {:ok, %Author{}} <- Authors.delete_author(author) do
          send_resp(conn, :no_content, "")
        end

      error ->
        error
    end
  end

  defp limit(params) do
    case Map.get(params, "limit", @default_limit)
         |> Integer.parse() do
      {limit, _} ->
        if limit > @max_limit, do: @default_limit, else: limit

      :error ->
        @default_limit
    end
  end

  defp offset(params) do
    case Map.get(params, "offset", @default_offset)
         |> Integer.parse() do
      {offset, _} ->
        offset

      :error ->
        @default_offset
    end
  end
end
