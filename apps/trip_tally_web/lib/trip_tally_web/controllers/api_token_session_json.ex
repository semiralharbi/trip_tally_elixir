defmodule TripTallyWeb.ApiTokenSessionJSON do
  def account_token(%{token: token, user: user}) do
    %{token: token, user: user_to_map(user)}
  end

  defp user_to_map(user) do
    %{
      id: user.id,
      email: user.email,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
