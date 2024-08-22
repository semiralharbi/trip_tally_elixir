defmodule TripTallyWeb.UserAuth do
  @moduledoc false

  use TripTallyWeb, :verified_routes

  import Plug.Conn

  alias TripTally.Accounts

  def fetch_current_user(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Accounts.fetch_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "You don't have access to this resource")
        |> halt()
    end
  end
end
