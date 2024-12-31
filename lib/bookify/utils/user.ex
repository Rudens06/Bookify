defmodule Bookify.Utils.User do
  alias Bookify.Users.User

  def current_user(struct) do
    struct.assigns.current_user
  end

  def is_admin?(nil), do: false

  def is_admin?(user) do
    User.admin_role() in user.roles
  end

  def is_resource_owner?(user, resource) do
    resource.user_id == user.id
  end
end
