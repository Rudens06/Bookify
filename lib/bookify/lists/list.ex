defmodule Bookify.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Users.User
  alias Bookify.Lists.ListBook
  alias Bookify.Books.Book

  @cast_fields [:name, :description]
  @required_fields [:name]
  @favorite_list_name "favorites"
  @wishlist_list_name "wishlist"
  @reading_list_name "reading list"

  schema "lists" do
    field :name, :string
    field :description, :string
    belongs_to :user, User
    many_to_many :books, Book, join_through: ListBook

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

  def favorite_list_name(), do: @favorite_list_name
  def wishlist_list_name(), do: @wishlist_list_name
  def reading_list_name(), do: @reading_list_name
end
