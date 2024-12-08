defmodule Bookify.Utils.Html do
  def clean_html(html) do
    html
    |> Floki.parse_fragment!()
    |> Floki.text()
  end
end
