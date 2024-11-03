defmodule BookifyWeb.Api.V1.ListJSON do
  alias Bookify.Lists.List

  @public_keys [:id, :name, :description]

  def index(%{lists: lists}) do
    %{data: for(list <- lists, do: data(list))}
  end

  def show(%{list: list}) do
    %{data: data(list)}
  end

  defp data(%List{} = list) do
    Map.take(list, @public_keys)
  end
end
