defmodule BookifyWeb.BookComponent do
  use BookifyWeb, :live_component
  import Bookify.Utils.Image

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
