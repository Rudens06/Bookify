defmodule Bookify.Lists do
  import Ecto.Query
  alias Bookify.Repo

  alias Bookify.Lists.List
  alias Bookify.Lists.ListsBooks

  def lists_by_user_id(user_id) do
    List
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def get_list!(id), do: Repo.get!(List, id)

  def create_list(user, attrs \\ %{}) do
    List.create_changeset(user, attrs)
    |> Repo.insert()
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  def get_list_book(list_id, book_id) do
    ListsBooks
    |> where(list_id: ^list_id, book_id: ^book_id)
    |> Repo.one!()
  end

  def add_book(%List{} = list, book, attrs \\ %{}) do
    ListsBooks.create_changeset(list, book, attrs)
    |> Repo.insert()
  end

  def remove_book(%ListsBooks{} = list_book) do
    Repo.delete(list_book)
  end

  def update_book_list(%ListsBooks{} = list_book, attrs \\ %{}) do
    ListsBooks.update_changeset(list_book, attrs)
    |> Repo.update()
  end
end
