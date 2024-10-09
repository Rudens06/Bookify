defmodule BookifyWeb.Api.V1.ReviewJSON do
  alias Bookify.Reviews.Review

  @public_keys [:id, :title, :body, :rating]

  def index(%{reviews: reviews}) do
    %{data: for(review <- reviews, do: data(review))}
  end

  def show(%{review: review}) do
    %{data: data(review)}
  end

  defp data(%Review{} = review) do
    Map.take(review, @public_keys)
  end
end
