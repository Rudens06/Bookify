defmodule BookifyWeb.AuthorLive.Index do
  use BookifyWeb, :live_view
  alias Bookify.Authors

  def mount(_params, _session, socket) do
    authors = Authors.list_authors()

    {:ok, stream(socket, :authors, authors)}
  end
end
