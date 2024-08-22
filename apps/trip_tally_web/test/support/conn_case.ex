defmodule TripTallyWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate
  import TripTally.Factory

  using do
    quote do
      # The default endpoint for testing
      @endpoint TripTallyWeb.Endpoint

      use TripTallyWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import TripTallyWeb.ConnCase
      import TripTally.Factory
    end
  end

  setup tags do
    TripTally.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that creates and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = insert(:user)
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn` and valid authorization token.
  """
  def log_in_user(conn, user) do
    api_token = TripTally.Accounts.create_user_api_token(user)

    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer " <> api_token)
  end
end
