defmodule BookifyWeb.Api.V1.AuthorJSON do
  alias Bookify.Authors.Author

  @public_keys [:id, :name, :birth_year, :death_year, :biography, :image_url, :wikipedia_url]

  def index(%{authors: authors}) do
    %{data: for(author <- authors, do: data(author))}
  end

  def show(%{author: author}) do
    %{data: data(author)}
  end

  defp data(%Author{} = author) do
    Map.take(author, @public_keys)
  end
end
