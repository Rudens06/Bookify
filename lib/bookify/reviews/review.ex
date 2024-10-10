defmodule Bookify.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Books.Book
  alias Bookfy.Users.User

  @cast_fields [:title, :body, :rating]
  @required_fields [:title, :rating]
  @allowed_statuses ["approved", "flagged", "rejected"]

  schema "reviews" do
    field :title, :string
    field :body, :string
    field :rating, :float
    field :status, :string, default: "approved"
    belongs_to :book, Book
    belongs_to :user, User

    timestamps()
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @allowed_statuses)
  end

  def create_changeset(book, user, attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> put_assoc(:book, book)
    |> put_assoc(:user, user)
  end
end
