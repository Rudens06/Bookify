defmodule Bookify.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Users.User
  alias Bookify.Lists.ListsBooks
  alias Bookify.Books.Book

  @cast_fields [:name, :description]
  @required_fields [:name]

  schema "lists" do
    field :name, :string
    field :description, :string
    belongs_to :user, User
    many_to_many :books, Book, join_through: ListsBooks

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  def create_changeset(user, attrs) do
    %__MODULE__{}
    |> cast(attrs, @cast_fields)
    |> put_assoc(:user, user)
    |> validate_required(@required_fields)
  end
end
