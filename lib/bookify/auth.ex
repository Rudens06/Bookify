defmodule Bookify.Auth do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Auth.Token

  @token_validity_in_days 30

  def generate_token(user_id) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.encode64()
    hashed_token = hashed_token(raw_token)

    expires_at =
      DateTime.add(DateTime.utc_now(), days_to_seconds(@token_validity_in_days), :second)

    attrs = %{token: hashed_token, expires_at: expires_at, user_id: user_id}

    Token.changset(attrs)
    |> Repo.insert()
  end

  def get_user_by_token(raw_token) do
    hashed_token = hashed_token(raw_token)

    query =
      from t in Token,
        where: t.token == ^hashed_token and t.expires_at > ^DateTime.utc_now(),
        join: u in assoc(t, :user),
        select: u

    Repo.one(query)
  end

  def invalidate_token(raw_token) do
    hashed_token = hashed_token(raw_token)
    Repo.delete(hashed_token)
  end

  defp hashed_token(raw_token) do
    Bcrypt.hash_pwd_salt(raw_token)
  end

  defp days_to_seconds(days) do
    days * 24 * 3600
  end
end
