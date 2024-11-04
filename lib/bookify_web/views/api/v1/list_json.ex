defmodule BookifyWeb.Api.V1.ListJSON do
  alias Bookify.Lists.ListBook
  alias Bookify.Lists.List

  @list_public_keys [:id, :name, :description]
  @list_book_public_keys [:list_id, :book_id, :page_stopped_at, :status, :notes]

  def index(%{lists: lists}) do
    %{data: for(list <- lists, do: list_data(list))}
  end

  def show(%{list: list}) do
    %{data: list_data(list)}
  end

  def add_book(%{list_book: list_book}) do
    %{data: list_book_data(list_book)}
  end

  def update_book(%{list_book: list_book}) do
    %{data: list_book_data(list_book)}
  end

  defp list_data(%List{} = list) do
    Map.take(list, @list_public_keys)
  end

  defp list_book_data(%ListBook{} = list_book) do
    Map.take(list_book, @list_book_public_keys)
  end
end
