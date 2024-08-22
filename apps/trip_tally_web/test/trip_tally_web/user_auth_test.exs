defmodule TripTallyWeb.UserAuthTest do
  use TripTallyWeb.ConnCase, async: true

  alias TripTally.Accounts
  alias TripTallyWeb.UserAuth

  setup do
    %{user: insert(:user)}
  end

  describe "fetch_current_user/2" do
    test "assigns user when token is valid", %{conn: conn, user: user} do
      token = Accounts.create_user_api_token(user)

      conn = put_req_header(conn, "authorization", "Bearer " <> token)

      conn = UserAuth.fetch_current_user(conn, [])

      assert conn.assigns.current_user.id == user.id
    end

    test "sends unauthorized response when token is invalid", %{conn: conn} do
      invalid_token = "invalid_token"

      conn = put_req_header(conn, "authorization", "Bearer " <> invalid_token)

      conn = UserAuth.fetch_current_user(conn, [])

      assert response(conn, 401) == "You don't have access to this resource"
      assert conn.halted
    end

    test "sends unauthorized response when authorization header is missing", %{conn: conn} do
      conn = UserAuth.fetch_current_user(conn, [])

      assert response(conn, 401) == "You don't have access to this resource"
      assert conn.halted
    end
  end
end
