defmodule Bookify.Utils.Integer do
  def validate_integer_id(id) do
    case Integer.parse(id) do
      {id, _} ->
        {:ok, id}

      _ ->
        {:error, "Invalid id"}
    end
  end
end
