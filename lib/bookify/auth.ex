defmodule Bookify.Auth do
  import Ecto.Query
  alias Bookify.Repo
  alias Bookify.Auth.Token

  @api_token_validity_in_days 30
  @remember_token_validity_in_days 30
  @api_context "api"
  @remember_me_context "remember"

  def generate_token(user_id, type) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()
    context = get_context(type)

    expires_at = expiration_by_context(context)
    attrs = %{token: token, context: context, expires_at: expires_at, user_id: user_id}

    Token.changset(attrs)
    |> Repo.insert()
  end

  def get_user_by_token(token, type) do
    context = get_context(type)

    token_context_query(token, context)
    |> user_query()
    |> Repo.one()
  end

  def invalidate_token(token) do
    token = Repo.get_by(Token, token: token)
    Repo.delete(token)
  end

  defp days_to_seconds(days) do
    days * 24 * 3600
  end

  defp user_query(query) do
    from t in query,
      join: u in assoc(t, :user),
      select: u
  end

  defp token_context_query(token, context) do
    from t in Token,
      where: t.token == ^token and t.context == ^context and t.expires_at > ^DateTime.utc_now()
  end

  defp get_context(type) do
    case type do
      :api -> @api_context
      :remember -> @remember_me_context
    end
  end

  defp expiration_by_context(context) do
    validity_in_days =
      case context do
        @api_context -> @api_token_validity_in_days
        @remember_me_context -> @remember_token_validity_in_days
      end

    DateTime.add(DateTime.utc_now(), days_to_seconds(validity_in_days), :second)
  end
end
