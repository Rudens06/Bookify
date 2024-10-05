defmodule BookifyWeb.ErrorJSONTest do
  use BookifyWeb.ConnCase, async: true

  test "renders 404" do
    assert BookifyWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BookifyWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
