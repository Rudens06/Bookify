defmodule Bookify.Books.Book do
  alias Bookify.Authors.Author
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [
    :title,
    :isbn,
    :genres,
    :publish_year,
    :page_count,
    :cover_image_url,
    :anotation,
    :author_id
  ]

  @required_fields [
    :title,
    :isbn,
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
    field :anotation, :string
    belongs_to :author, Author

    timestamps()
  end

  def changeset(book, attrs) do
    book
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:isbn])
  end
end
