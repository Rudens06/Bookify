defmodule Bookify.Auth.UserToken do
  import Ecto.Query
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Auth.UserToken
  alias Bookify.Users.User

  @api_context "api"
  @session_context "session"
  @api_token_validity_in_days 30
  @session_token_validity_in_days 30

  @cast_fields [:token, :expires_at, :user_id]
  @required_fields [:token, :expires_at, :user_id]
  @token_contexts [@api_context, @session_context]

  schema("user_tokens") do
    field :token, :string
    field :expires_at, :utc_datetime
    field :context, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  def changset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:context, @token_contexts)
    |> unique_constraint(:token)
  end

  def build_token(user_id, type) do
    token =
      :crypto.strong_rand_bytes(32)
      |> encode_token()

    context = get_context(type)
    expires_at = expiration_by_context(context)

    user_token = %UserToken{
      token: token,
      context: context,
      expires_at: expires_at,
      user_id: user_id
    }

    {token, user_token}
  end

  defp expiration_by_context(context) do
    validity_in_days =
      case context do
        @api_context -> @api_token_validity_in_days
        @session_context -> @session_token_validity_in_days
      end

    DateTime.add(DateTime.utc_now(), days_to_seconds(validity_in_days), :second)
    |> DateTime.truncate(:second)
  end

  defp days_to_seconds(days) do
    days * 24 * 3600
  end

  def decode_token(token) do
    Base.url_decode64!(token)
  end

  def encode_token(token) do
    Base.url_encode64(token)
  end

  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, contexts) when is_list(contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end

  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  def get_context(:api), do: @api_context
  def get_context(:session), do: @session_context
end
