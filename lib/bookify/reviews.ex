defmodule Bookify.Reviews do
  import Ecto.Query
  alias Bookify.Repo

  alias Bookify.Reviews.Review

  def list_reviews(opts \\ []) do
    query =
      from(r in Review)

    query =
      case Keyword.get(opts, :book_id) do
        nil -> query
        book_id -> from r in query, where: r.book_id == ^book_id
      end

    query =
      case Keyword.get(opts, :user_id) do
        nil -> query
        user_id -> from r in query, where: r.user_id == ^user_id
      end

    Repo.all(query)
  end

  def get_review!(id), do: Repo.get!(Review, id)

  def create_review(book, user, attrs \\ %{}) do
    Review.create_changeset(book, user, attrs)
    |> Repo.insert()
  end

  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end
end