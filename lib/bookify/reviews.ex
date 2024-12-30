defmodule Bookify.Reviews do
  import Ecto.Query
  alias Bookify.Repo

  alias Bookify.Reviews.Review

  @not_found_message "Review not found"

  def list_reviews() do
    Repo.all(Review)
  end

  def list_user_reviews(user_id, preloads \\ []) do
    Review
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  def list_book_reviews(book_id) do
    Review
    |> where(book_id: ^book_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:user])
  end

  def get_review(id) do
    case Repo.get(Review, id) do
      nil ->
        not_found()

      review ->
        review
    end
  end

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

  defp not_found() do
    {:error, {:not_found, @not_found_message}}
  end
end
