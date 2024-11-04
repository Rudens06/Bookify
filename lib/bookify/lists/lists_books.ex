defmodule Bookify.Lists.ListsBooks do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Lists.List
  alias Bookify.Books.Book

  @cast_fields [:page_stopped_at, :status, :notes]
  @allowed_statuses ["completed", "paused"]

  @primary_key false
  schema "lists_books" do
    belongs_to :list, List, primary_key: true
    belongs_to :book, Book, primary_key: true
    field :page_stopped_at, :integer
    field :status, :string
    field :notes, :string

    timestamps()
  end

  def create_changeset(list, book, attrs) do
    %__MODULE__{}
    |> cast(attrs, @cast_fields)
    |> put_assoc(:list, list)
    |> put_assoc(:book, book)
    |> unique_constraint(:no_duplicate_books_in_list, name: :lists_books_pkey)
    |> validate_status()
  end

  def update_changeset(list_book, attrs) do
    list_book
    |> cast(attrs, @cast_fields)
    |> validate_status()
  end

  defp validate_status(changeset) do
    if get_change(changeset, :status) do
      validate_inclusion(changeset, :status, @allowed_statuses)
    else
      changeset
    end
  end
end
