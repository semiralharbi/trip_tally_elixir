defmodule TripTallyWeb.User.UserController do
  use TripTallyWeb.AuthController

  alias TripTally.Accounts
  alias TripTally.Media
  alias TripTallyWeb.User.TokenJSON

  @doc """
  Purpose: Authenticates user with JWT token to the app.

  Endpoint: POST /api/users/log_in

  Parameters:

  email (String): Email of the signed up user.
  password (String): Password of the user.

  Returns: JSON with JWT token, which should be saved and used for authenticated requests.
  Failure: If the password or email are unsuccessful returns Invalid email or password.
  """
  def log_in(conn, %{"email" => email, "password" => password}, _) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        {:error, :invalid_email_or_pass}

      user ->
        token = Accounts.create_user_api_token(user)

        conn
        |> put_status(:ok)
        |> put_view(TokenJSON)
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
  def register(conn, user_params, _) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = Accounts.create_user_api_token(user)

        conn
        |> put_status(:created)
        |> put_view(TokenJSON)
        |> render(:account_token, %{token: token, user: user})

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Purpose: Updates the user's profile information (country, default_currency_code, profile picture, and username).

  Endpoint: PUT /api/users/update_profile

  Parameters:
  - country (String): New country of the user.
  - default_currency_code (String): New default currency of the user.
  - username (String): New username of the user.
  - profile_picture (File): Profile picture file uploaded by the user.

  Returns: JSON with the updated user information.
  """
  def update_profile(_conn, %{"profile_picture" => profile_picture} = args, user)
      when not is_nil(profile_picture) do
    case Media.upload_image(user, profile_picture) do
      {:ok, _attachment} ->
        case Accounts.update_user_profile(user, args) do
          {:ok, _updated_user} ->
            {:ok, :accepted}

          error ->
            error
        end

      error ->
        error
    end
  end

  def update_profile(_conn, args, user) do
    case Accounts.update_user_profile(user, args) do
      {:ok, _updated_user} ->
        {:ok, :accepted}

      error ->
        error
    end
  end
end
