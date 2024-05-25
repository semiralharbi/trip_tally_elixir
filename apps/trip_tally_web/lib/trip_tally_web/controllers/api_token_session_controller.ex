defmodule TripTallyWeb.ApiTokenSessionController do
  use TripTallyWeb, :controller

  alias TripTally.Accounts
  alias TripTallyWeb.UserAuth

  @doc """
  Purpose: Authenticates user with JWT token to the app.

  Endpoint: POST /api/users/log_in

  Parameters:

  email (String): Email of the signed up user.
  password (String): Password of the user.

  Returns: JSON with JWT token, which should be saved and used for authenticated requests.
  Failure: If the password or email are unsuccessful returns Invalid email or password.
  """
  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user_api_token(conn, user)
    else
      conn |> put_status(401) |> json("Invalid email or password")
    end
  end
end
