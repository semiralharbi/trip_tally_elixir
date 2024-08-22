defmodule TripTallyWeb.User.TokenJSON do
  def account_token(%{token: token, user: user}) do
    %{token: token, user: user}
  end
end
