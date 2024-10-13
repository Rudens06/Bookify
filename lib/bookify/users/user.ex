defmodule Bookify.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bookify.Utils.GenId
  alias Bookify.Reviews.Review

  @login_fields [:email, :password]
  @required_login_fields [:email, :password]

  @register_fields [:name, :email, :password, :password_confirmation]
  @required_register_fields [:name, :email, :password, :password_confirmation]
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
    field :public, :boolean, default: true
    has_many :reviews, Review

    timestamps()
  end

  def update_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @update_fields)
  end

  def login_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @login_fields)
    |> validate_required(@required_login_fields)
    |> update_last_login()
  end

  def registration_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @register_fields)
    |> validate_required(@required_register_fields)
    |> put_public_id()
    |> hash_password()
    |> update_last_login()
  end

  defp put_public_id(changeset) do
    changeset
    |> put_change(:public_id, GenId.generate())
  end

  def valid_password?(password, hashed_password) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  defp hash_password(changeset) do
    password = get_field(changeset, :password)

    if changeset.valid? && password do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end

  defp update_last_login(changeset) do
    timestamp =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    changeset
    |> put_change(:last_login, timestamp)
  end
end
