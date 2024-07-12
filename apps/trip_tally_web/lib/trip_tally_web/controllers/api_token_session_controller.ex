defmodule TripTallyWeb.ApiTokenSessionController do
  use TripTallyWeb, :controller

  alias TripTallyWeb.ApiTokenSessionJSON
  alias TripTally.Accounts
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
  def log_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        {:error, :invalid_email_or_pass}

      user ->
        token = Accounts.create_user_api_token(user)

        conn
        |> put_status(:ok)
        |> put_view(ApiTokenSessionJSON)
        |> render(:account_token, %{token: token, user: user})
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
        |> put_view(ApiTokenSessionJSON)
        |> render(:account_token, %{token: token, user: user})

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
