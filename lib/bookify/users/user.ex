defmodule Bookify.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bookify.Utils.GenId
  alias Bookify.Reviews.Review

  @register_fields [:username, :email, :password, :password_confirmation]
  @required_register_fields [:username, :email, :password, :password_confirmation]
  @update_fields [:username, :name]

  schema("users") do
    field :public_id, :string
    field :name, :string
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :roles, {:array, :string}, default: []
    field :last_login, :utc_datetime
    has_many :reviews, Review

    timestamps()
  end

  def registration_changeset(attrs) do
    new()
    |> cast(attrs, [@register_fields])
    |> validate_required(@required_register_fields)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [@update_fields])
  end

  defp new() do
    %__MODULE__{public_id: GenId.generate()}
  end
end
