defmodule Bookify.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bookify.Utils.GenId

  @cast_fields [:name, :username, :email, :password, :password_confirmation, :current_password]
  @required_fields [:name, :email, :password]

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

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [@cast_fields])
    |> validate_required(@required_fields)
  end

  def registration_changeset(attrs) do
    new()
    |> cast(attrs, [@cast_fields])
    |> validate_required(@required_fields)
  end

  def new() do
    %__MODULE__{public_id: GenId.generate()}
  end
end
