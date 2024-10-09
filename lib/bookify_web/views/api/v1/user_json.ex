defmodule BookifyWeb.Api.V1.UserJSON do
  alias Bookify.Users.User

  @public_keys [:id, :name, :username]

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    Map.take(user, @public_keys)
  end
end
