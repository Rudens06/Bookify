defmodule Bookify.Utils.User do
  def current_user(struct) do
    struct.assigns.current_user
  end

  def is_admin?(user) do
    "admin" in user.roles
  end
end
