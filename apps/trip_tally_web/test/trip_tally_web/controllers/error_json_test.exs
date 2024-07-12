defmodule TripTallyWeb.ErrorJSONTest do
  use TripTallyWeb.ConnCase, async: true

  test "renders 404" do
    assert TripTallyWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: "Not Found"
           }
  end

  test "renders 500" do
    assert TripTallyWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: "Internal Server Error"}
  end

  test "renders 403" do
    assert TripTallyWeb.ErrorJSON.render("403.json", %{}) ==
             %{errors: "Forbidden"}
  end

  test "renders 400" do
    assert TripTallyWeb.ErrorJSON.render("400.json", %{}) ==
             %{errors: "Bad Request"}
  end

  test "renders 401" do
    assert TripTallyWeb.ErrorJSON.render("401.json", %{}) ==
             %{errors: "Unauthorized"}
  end

  test "renders 422" do
    assert TripTallyWeb.ErrorJSON.render("422.json", %{}) ==
             %{errors: "Unprocessable Entity"}
  end
end
