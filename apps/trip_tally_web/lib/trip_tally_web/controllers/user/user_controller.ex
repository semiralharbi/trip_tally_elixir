defmodule TripTallyWeb.User.UserController do
  use TripTallyWeb.AuthController

  alias TripTally.Accounts
  alias TripTally.Media

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
