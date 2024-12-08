defmodule Bookify.Users do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Users.User
  alias Bookify.Auth.UserToken

  @not_found_message "User not found"

  def list_users do
    Repo.all(User)
  end

  def search_users(query, exclude_user_id, preloads \\ []) do
    query = "%#{query}%"

    Repo.all(
      from a in User,
        where: ilike(a.name, ^query),
        where: a.id != ^exclude_user_id,
        preload: ^preloads
    )
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_public_id(id) do
    case Repo.get_by(User, public_id: id) do
      nil ->
        not_found()

      user ->
        user
    end
  end

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

  def generate_new_api_token(user) do
    generate_token(user.id, :api)
  end

  def generate_token(user_id, type) when type in [:api, :session] do
    {token, user_token} =
      UserToken.build_token(user_id, type)

    user_token = Repo.insert!(user_token)
    {token, user_token}
  end

  def get_users_tokens(user, type) when type in [:api, :session] do
    context = UserToken.get_context(type)

    user_token_context_query(user.id, context)
    |> Repo.all()
  end

  def get_token_by_id(user, token_id) do
    user_token_id_query(user.id, token_id)
    |> Repo.one()
  end

  def delete_token_by_id(user, token_id) do
    user_token_id_query(user.id, token_id)
    |> Repo.delete!()
  end

  def invalidate_token(token) do
    Repo.get_by(UserToken, token: token)
    |> Repo.delete()
  end

  def invalidate_tokens(user, type) do
    context = UserToken.get_context(type)

    UserToken.by_user_and_contexts_query(user, [context])
    |> Repo.delete_all()
  end

  def get_user_by_token(token, type) do
    context = UserToken.get_context(type)

    valid_token_context_query(token, context)
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

  defp user_token_id_query(user_id, token_id) do
    from t in UserToken,
      where: t.id == ^token_id and t.user_id == ^user_id
  end

  defp valid_token_context_query(token, context) do
    from t in UserToken,
      where: t.token == ^token and t.context == ^context and t.expires_at > ^DateTime.utc_now()
  end

  defp user_token_context_query(user_id, context) do
    from t in UserToken,
      where: t.context == ^context and t.user_id == ^user_id
  end

  defp user_query(query) do
    from t in query,
      join: u in assoc(t, :user),
      select: u
  end

  defp not_found() do
    {:error, {:not_found, @not_found_message}}
  end
end
