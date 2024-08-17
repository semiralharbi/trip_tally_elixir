defmodule TripTallyWeb.UserControllerTest do
  alias TripTally.Accounts.User
  alias TripTally.Repo
  use TripTallyWeb.ConnCase, async: true

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
