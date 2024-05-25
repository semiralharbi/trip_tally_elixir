defmodule TripTallyWeb.ApiTokenSessionJSON do
  def account_token(%{token: token}) do
    %{token: token}
  end
end
