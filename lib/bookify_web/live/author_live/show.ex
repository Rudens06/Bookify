defmodule BookifyWeb.AuthorLive.Show do
  use BookifyWeb, :live_view
  alias Bookify.Authors

  def mount(%{"id" => id}, _session, socket) do
    author = Authors.get_author(id, [:books])
    {:ok, assign(socket, :author, author)}
  end
end
