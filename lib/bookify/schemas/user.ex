defmodule Bookify.User do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import BookifyWeb.Gettext

  alias Bookify.GenId
  alias Bookify.Avatar
  alias Bookify.Review

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :string, autogenerate: false}
  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :roles, {:array, :string}
    field :last_login, :utc_datetime
    field :avatar, Avatar.Type
    has_many :reviews, Review

    timestamps()
  end

  def avatar_changeset(user, params \\ %{}) do
    user
    |> cast(params, [])
    |> cast_attachments(params, [:avatar])
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :password, :password_confirmation])
  end

  def edit_profile_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
    |> unique_constraint([:email])
  end

  def edit_password_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:password, :password_confirmation, :current_password])
    |> validate_required([:password, :password_confirmation, :current_password])
    |> validate_password()
    |> validate_confirmation(:password, message: gettext("Passwords do not match"))
    |> hash_password()
  end

  def sign_in_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_email()
  end

  def last_login_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    user
    |> change(last_login: now)
  end

  def registration_changeset(user, params \\ %{}) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    user
    |> cast(params, [:name, :email, :password, :password_confirmation])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> unique_constraint([:email])
    |> validate_email()
    |> validate_password()
    |> validate_confirmation(:password, message: gettext("Passwords do not match"))
    |> change(last_login: now)
    |> hash_password()
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(
      :password,
      min: 8,
      message: gettext("Must be at least 8 characters")
    )
    |> validate_length(
      :password,
      max: 72,
      message: gettext("Must not be longer than 72 characters")
    )
    |> validate_format(:password, ~r/[a-z]/,
      message: gettext("Must contain at least one lower case character")
    )
    |> validate_format(:password, ~r/[A-Z]/,
      message: gettext("Must contain at least one upper case character")
    )
    |> validate_format(:password, ~r/[0-9]/, message: gettext("Must contain at least one digit"))
    |> validate_format(:password, ~r/[*.!@#$%^&(){}[:;<>,.?]/,
      message: gettext("Must contain at least one symbol")
    )
  end

  def validate_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[^\s]+@[^\s]+$/,
      message: gettext("must have the @ sign and no spaces")
    )
    |> validate_length(
      :email,
      max: 160,
      message: gettext("should be at most 160 characters long")
    )
  end

  def new() do
    %__MODULE__{id: GenId.generate()}
  end
end
