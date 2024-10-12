defmodule Bookify.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Users.User

  @cast_fields [:token, :expires_at, :user_id]
  @required_fields [:token, :expires_at, :user_id]
  @token_contexts ["api", "remember"]

  schema("user_tokens") do
    field :token, :string
    field :expires_at, :string
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
end
