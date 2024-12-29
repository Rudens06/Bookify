defmodule Bookify.Utils.User do
  alias Bookify.Users.User

  def current_user(struct) do
    struct.assigns.current_user
  end

  def is_admin?(user) do
    User.admin_role() in user.roles
  end
end
