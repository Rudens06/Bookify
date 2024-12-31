defmodule BookifyWeb.Api.V1.BookJSON do
  alias Bookify.Books.Book

  @public_keys [
    :isbn,
    :title,
    :author_id,
    :genres,
    :publish_year,
    :page_count,
    :cover_image_url,
    :avg_rating,
    :review_count,
    :anotation
  ]

  def index(%{books: books}) do
    %{data: for(book <- books, do: data(book))}
  end

  def show(%{book: book}) do
    %{data: data(book)}
  end

  defp data(%Book{} = book) do
    Map.take(book, @public_keys)
  end
end
