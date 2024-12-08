defmodule Bookify.Lists do
  import Ecto.Query
  alias Bookify.Repo

  alias Bookify.Lists.List
  alias Bookify.Lists.ListBook

  @list_not_found_message "List not found"
  @list_book_not_found_message "Book not in the list"

  def lists_by_user_id(user_id) do
    List
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def get_list(id, user_id) do
    case Repo.get_by(List, id: id, user_id: user_id) do
      nil ->
        list_not_found()

      list ->
        list
    end
  end

  def get_list_by_name(name, user_id, preloads \\ []) do
    case Repo.get_by(List, name: name, user_id: user_id) do
      nil ->
        list_not_found()

      list ->
        list
        |> Repo.preload(preloads)
    end
  end

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
    query =
      ListBook
      |> where(list_id: ^list_id, book_id: ^book_id)

    case Repo.one(query) do
      nil ->
        list_book_not_found()

      list_book ->
        list_book
    end
  end

  def add_book(%List{} = list, book, attrs \\ %{}) do
    ListBook.create_changeset(list, book, attrs)
    |> Repo.insert()
  end

  def remove_book(%ListBook{} = list_book) do
    Repo.delete(list_book)
  end

  def update_book_list(%ListBook{} = list_book, attrs \\ %{}) do
    ListBook.update_changeset(list_book, attrs)
    |> Repo.update()
  end

  def has_book?(list, book_id) do
    Repo.exists?(book_in_list_query(list, book_id))
  end

  defp book_in_list_query(list, book_id) do
    from(lb in ListBook, where: lb.list_id == ^list.id and lb.book_id == ^book_id)
  end

  defp list_not_found() do
    {:error, {:not_found, @list_not_found_message}}
  end

  defp list_book_not_found() do
    {:error, {:not_found, @list_book_not_found_message}}
  end
end
