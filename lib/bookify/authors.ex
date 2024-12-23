defmodule Bookify.Authors do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Authors.Author

  @not_found_message "Author not found"

  def list_authors() do
    Repo.all(Author, order_by: [asc: :name])
  end

  def list_authors(limit, offset) do
    Repo.all(
      from a in Author,
        limit: ^limit,
        offset: ^offset,
        order_by: [asc: :name]
    )
  end

  def get_author(id, preloads \\ []) do
    case Repo.get(Author, id) |> Repo.preload(preloads) do
      nil ->
        not_found()

      author ->
        author
    end
  end

  def search_authors(query, limit, offset, preloads \\ []) do
    query = "%#{query}%"

    Repo.all(
      from a in Author,
        where: ilike(a.name, ^query),
        limit: ^limit,
        offset: ^offset,
        preload: ^preloads
    )
  end

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  def create_if_not_exists(name) do
    case Repo.get_by(Author, name: name) do
      nil ->
        changeset = Author.minimal_changeset(%Author{}, %{"name" => name})

        case Repo.insert(changeset) do
          {:ok, author} ->
            {:ok, author}

          {:error, changeset} ->
            {:error, changeset}
        end

      author ->
        {:ok, author}
    end
  end

  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  defp not_found() do
    {:error, {:not_found, @not_found_message}}
  end
end
