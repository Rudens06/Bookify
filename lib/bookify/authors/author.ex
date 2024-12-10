defmodule Bookify.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Books.Book

  @cast_fields [:name, :birth_year, :biography, :image_url, :wikipedia_url]
  @required_fields [:name, :birth_year, :biography]

  schema "authors" do
    field :name, :string
    field :birth_year, :integer
    field :biography, :string
    field :image_url, :string
    field :wikipedia_url, :string
    has_many :books, Book

    timestamps()
  end

  def changeset(author, attrs) do
    author
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  def minimal_changeset(author, attrs) do
    author
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
