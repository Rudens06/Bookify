defmodule Bookify.Authors do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Authors.Author

  @not_found_message "Author not found"

  def list_authors do
    Repo.all(Author)
  end

  def get_author(id, preloads \\ []) do
    case Repo.get(Author, id) |> Repo.preload(preloads) do
      nil ->
        not_found()

      author ->
        author
    end
  end

  def search_authors(query, preloads \\ []) do
    query = "%#{query}%"

    Repo.all(
      from a in Author,
        where: ilike(a.name, ^query),
        preload: ^preloads
    )
  end

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
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
