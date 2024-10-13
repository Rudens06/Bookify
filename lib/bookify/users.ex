defmodule Bookify.Users do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Users.User
  alias Bookify.Auth.UserToken

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_public_id!(id), do: Repo.get_by!(User, public_id: id)

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def create_user(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
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

  def generate_new_api_key(user) do
    invalidate_tokens(user, :api)
    generate_token(user.id, :api)
  end

  def generate_token(user_id, type) when type in [:api, :session] do
    {token, user_token} =
      UserToken.build_token(user_id, type)

    Repo.insert!(user_token)
    token
  end

  def invalidate_token(token, type) do
    context = UserToken.get_context(type)

    UserToken.by_token_and_context_query(token, context)
    |> Repo.delete_all()
  end

  def invalidate_tokens(user, type) do
    context = UserToken.get_context(type)

    UserToken.by_user_and_contexts_query(user, [context])
    |> Repo.delete_all()
  end

  def get_user_by_token(token, type) do
    context = UserToken.get_context(type)

    token_context_query(token, context)
    |> user_query()
    |> Repo.one()
  end

  def get_user_by_email_and_password(email, password) do
    user = get_user_by_email(email)

    if user && User.valid_password?(password, user.hashed_password) do
      user
    else
      nil
    end
  end

  defp token_context_query(token, context) do
    from t in UserToken,
      where: t.token == ^token and t.context == ^context and t.expires_at > ^DateTime.utc_now()
  end

  defp user_query(query) do
    from t in query,
      join: u in assoc(t, :user),
      select: u
  end
end
