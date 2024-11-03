defmodule Bookify.Lists do
  import Ecto.Query
  alias Bookify.Repo

  alias Bookify.Lists.List

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
end
