defmodule TripTallyWeb.ApiTokenSessionController do
  use TripTallyWeb, :controller

  alias TripTally.Accounts
  alias TripTallyWeb.UserAuth
  action_fallback TripTallyWeb.FallbackController

  @doc """
  Purpose: Authenticates user with JWT token to the app.

  Endpoint: POST /api/users/log_in

  Parameters:

  email (String): Email of the signed up user.
  password (String): Password of the user.

  Returns: JSON with JWT token, which should be saved and used for authenticated requests.
  Failure: If the password or email are unsuccessful returns Invalid email or password.
  """
  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil -> {:error, :invalid_email_or_pass}
      user -> UserAuth.log_in_user_api_token(conn, user)
    end
  end

  @doc """
  Purpose: Registers a new user and returns an API token.

  Endpoint: POST /api/users/register

  Parameters:
  - email (String): Email of the new user.
  - password (String): Password of the new user.

  Returns: JSON with an API token, which should be saved and used for authenticated requests.
  """
  def register(conn, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = Accounts.create_user_api_token(user)

        conn
        |> put_status(:created)
        |> render(:account_token, token: token)

      {:error, changeset} ->
        {:error, changeset}

      e ->
        IO.inspect(e)
    end
  end
end
