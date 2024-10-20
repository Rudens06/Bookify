defmodule Bookify.Utils.User do
  def current_user(struct) do
    struct.assigns.current_user
  end
end
