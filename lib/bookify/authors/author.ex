defmodule Bookify.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :birth_year, :integer
    field :death_year, :integer
    field :biography, :string
    field :image_url, :string
    field :wikipedia_url, :string

    timestamps()
  end

  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :birth_year, :death_year, :biography, :image_url, :wikipedia_url])
    |> validate_required([:name])
  end
end
