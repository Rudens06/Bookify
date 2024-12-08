defmodule Bookify.Utils.Book do
  def select_options(list_of_structs) do
    list_of_structs
    |> Enum.map(&{&1.name, &1.id})
  end
end
