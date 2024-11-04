defmodule Bookify.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Books.Book

  @cast_fields [:name, :birth_year, :death_year, :biography, :image_url, :wikipedia_url]
  @required_fields [:name]

  schema "authors" do
    field :name, :string
    field :birth_year, :integer
    field :death_year, :integer
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
end
