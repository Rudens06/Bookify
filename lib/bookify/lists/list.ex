defmodule Bookify.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bookify.Users.User

  @cast_fields [:name, :description]
  @required_fields [:name]

  schema "lists" do
    field :name, :string
    field :description, :string
    belongs_to :user, User

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  def create_changeset(user, attrs) do
    %__MODULE__{}
    |> cast(attrs, @cast_fields)
    |> put_assoc(:user, user)
    |> validate_required(@required_fields)
  end
end
