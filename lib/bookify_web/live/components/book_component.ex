defmodule BookifyWeb.BookComponent do
  use BookifyWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end