defmodule TripTallyWeb.ApiTokenSessionControllerTest do
  use TripTallyWeb.ConnCase

  import TripTally.AccountsFixtures

  @user_attrs %{
    :email => "user@example.com",
    :password => "Password1!"
  }
  @create_attrs %{
    :user => @user_attrs
  }

  describe "create" do
    test "renders user token when data is valid", %{conn: conn} do
      user_fixture(@user_attrs)
      conn = post(conn, "/api/users/log_in", @create_attrs)
      assert %{"token" => _token} = json_response(conn, 200)
    end

    test "renders invalid email or password when the data is not valid", %{conn: conn} do
      conn = post(conn, "/api/users/log_in", @create_attrs)

      assert "Invalid email or password" = json_response(conn, 401)
    end
  end
end
