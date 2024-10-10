defmodule Bookify.Users do
  alias Bookify.Repo
  alias Bookify.Users.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_public_id!(id), do: Repo.get_by!(User, public_id: id)

  def create_user(attrs \\ %{}) do
    User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
