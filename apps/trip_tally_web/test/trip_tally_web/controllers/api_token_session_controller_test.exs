defmodule TripTallyWeb.ApiTokenSessionControllerTest do
  use TripTallyWeb.ConnCase

  import TripTally.AccountsFixtures

  @user_attrs %{
    :email => "user@example.com",
    :password => "Password1!"
  }
  @user_invalid_attrs %{
    :email => "user@example.com",
    :password => "pa"
  }

  describe "create" do
    test "renders user token when data is valid", %{conn: conn} do
      user_fixture(@user_attrs)
      conn = post(conn, "/api/users/log_in", @user_attrs)
      assert %{"token" => _token} = json_response(conn, 200)
    end

    test "renders invalid email or password when the data is not valid", %{conn: conn} do
      conn = post(conn, "/api/users/log_in", @user_attrs)
      assert %{"error" => "Invalid email or password"} = json_response(conn, 401)
    end
  end

  describe "register" do
    test "renders user token when data is valid", %{conn: conn} do
      conn = post(conn, "/api/users/register", @user_attrs)
      assert %{"token" => _token} = json_response(conn, 201)
    end

    test "renders invalid email or password when the data is not valid", %{conn: conn} do
      conn = post(conn, "/api/users/register", @user_invalid_attrs)

      assert %{
               "errors" => %{
                 "password" => [
                   "at least one digit or punctuation character",
                   "at least one upper case character",
                   "should be at least 8 character(s)"
                 ]
               }
             } = json_response(conn, 422)
    end

    test "renders error when user already exists", %{conn: conn} do
      user_fixture(@user_attrs)

      conn = post(conn, "/api/users/register", @user_attrs)
      assert %{"errors" => %{"email" => ["has already been taken"]}} = json_response(conn, 422)
    end
  end
end
