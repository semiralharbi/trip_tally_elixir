defmodule TripTallyWeb.UserControllerTest do
  alias TripTally.Accounts.User
  alias TripTally.Repo

  use TripTallyWeb.ConnCase, async: true

  @new_user_attrs %{
    email: "user1@example.com",
    password: "Password1!"
  }
  @user_invalid_attrs %{
    :email => "user@example.com",
    :password => "pa"
  }

  setup do
    {:ok, user: insert(:user)}
  end

  describe "log_in" do
    test "renders user token when data is valid", %{
      conn: conn,
      user: %{id: id, email: email, password: password}
    } do
      attrs = %{email: email, password: password}

      conn = post(conn, "/api/users/log_in", attrs)

      assert %{
               "token" => _,
               "user" => %{
                 "id" => ^id,
                 "email" => ^email
               }
             } = json_response(conn, 200)
    end

    test "renders invalid email or password when the data is not valid", %{conn: conn} do
      conn = post(conn, "/api/users/log_in", @user_invalid_attrs)
      assert %{"errors" => "Invalid email or password"} = json_response(conn, 401)
    end
  end

  describe "register" do
    test "renders user token when data is valid", %{conn: conn} do
      conn = post(conn, "/api/users/register", @new_user_attrs)

      assert %{
               "token" => _,
               "user" => %{
                 "email" => "user1@example.com"
               }
             } = json_response(conn, 201)
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

    test "renders error when user already exists", %{
      conn: conn,
      user: %{email: email, password: password}
    } do
      attrs = %{email: email, password: password}
      conn = post(conn, "/api/users/register", attrs)
      assert %{"errors" => %{"email" => ["has already been taken"]}} = json_response(conn, 422)
    end
  end

  describe "update_profile" do
    setup :register_and_log_in_user

    test "update profile success without profile picture", %{conn: conn} do
      attrs = %{
        "country" => "United States",
        "default_currency_code" => "USD",
        "username" => "TestUsername"
      }

      assert %{"status" => "success"} ==
               conn
               |> put("/api/users/update_profile", attrs)
               |> json_response(202)
    end

    test "update profile success with profile picture", %{conn: conn, user: user} do
      attrs = %{
        "country" => "United States",
        "default_currency_code" => "USD",
        "username" => "TestUsername",
        "profile_picture" => %Plug.Upload{
          filename: "test.jpg",
          path: "test/support/assets/test.jpg",
          content_type: "image/jpeg"
        }
      }

      assert %{"status" => "success"} ==
               conn
               |> put("/api/users/update_profile", attrs)
               |> json_response(202)

      updated_user = Repo.get(User, user.id) |> Repo.preload(:profile_picture)
      assert updated_user.profile_picture != nil
      assert updated_user.profile_picture.filename == "test.jpg"

      File.rm(updated_user.profile_picture.url)
    end

    test "update profile wrong currency code", %{conn: conn} do
      attrs = %{
        "country" => "United States",
        "default_currency_code" => "USDSD",
        "username" => "TestUsername"
      }

      assert %{"errors" => %{"default_currency_code" => ["should be at most 3 character(s)"]}} ==
               conn
               |> put("/api/users/update_profile", attrs)
               |> json_response(422)
    end

    test "update profile country too long", %{conn: conn} do
      attrs = %{
        "country" => "United States United States United States United States United States",
        "default_currency_code" => "USD",
        "username" => "TestUsername"
      }

      assert %{"errors" => %{"country" => ["should be at most 60 character(s)"]}} ==
               conn
               |> put("/api/users/update_profile", attrs)
               |> json_response(422)
    end

    test "update profile username too long", %{conn: conn} do
      attrs = %{
        "country" => "United States",
        "default_currency_code" => "USD",
        "username" => "TestUsernameTestUsernameTestUsernameTestUsernameTestUsername"
      }

      assert %{"errors" => %{"username" => ["should be at most 20 character(s)"]}} ==
               conn
               |> put("/api/users/update_profile", attrs)
               |> json_response(422)
    end
  end
end
