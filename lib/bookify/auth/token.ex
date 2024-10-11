defmodule Bookify.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Users.User

  @cast_fields [:token, :expires_at, :user_id]
  @required_fields [:token, :expires_at, :user_id]

  schema("tokens") do
    field :hashed_token, :string
    field :expires_at, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  def changset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:token)
  end
end
