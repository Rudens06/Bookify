defmodule Bookify.Books.Book do
  alias Bookify.Authors.Author
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Reviews.Review

  @cast_fields [
    :title,
    :isbn,
    :genres,
    :publish_year,
    :page_count,
    :cover_image_url,
    :cover_image_filename,
    :anotation,
    :author_id
  ]

  @required_fields [
    :title,
    :isbn,
    :genres,
    :publish_year,
    :page_count,
    :anotation,
    :author_id
  ]

  schema "books" do
    field :title, :string
    field :isbn, :string
    field :genres, {:array, :string}, default: []
    field :publish_year, :integer
    field :page_count, :integer
    field :cover_image_url, :string
    field :cover_image_filename, :string
    field :anotation, :string
    belongs_to :author, Author
    has_many :reviews, Review

    timestamps()
  end

  def changeset(book, attrs \\ %{}) do
    book
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:isbn])
    |> validate_genres()
  end

  defp validate_genres(changeset) do
    genres = get_field(changeset, :genres)

    if is_nil(genres) or genres == [] do
      add_error(changeset, :genres, "can't be blank")
    else
      changeset
    end
  end
end
