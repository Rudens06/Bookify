defmodule Bookify.Accounts do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.User
  alias Bookify.Review

  def list_users() do
    User
    |> order_by(desc: :last_login)
    |> Repo.all()
  end

  def get_user_by_id!(user_id) do
    Repo.get!(User, user_id)
  end

  def get_user_by_id_w_preloads(user_id) do
    reviews_query = from r in Review, order_by: [desc: r.inserted_at]

    Repo.get!(User, user_id)
    |> Repo.preload(reviews: reviews_query)
    |> Repo.preload(reviews: [:book])
  end

  def insert(user) do
    Repo.insert(user)
  end

  def update(user) do
    Repo.update(user)
  end

  def delete_user_by_id!(user_id) do
    Repo.get(User, user_id)
    |> Repo.delete!
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def update_user_avatar(%User{} = user, attrs) do
    user
    |> User.avatar_changeset(attrs)
    |> Repo.update()
  end

  def change_user_avatar(%User{} = user) do
    User.avatar_changeset(user, %{})
  end
end
