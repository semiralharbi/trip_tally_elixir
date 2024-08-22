defmodule TripTally.Factory do
  @moduledoc """
  Factories for all schemas
  """

  use ExMachina.Ecto, repo: TripTally.Repo

  alias Bcrypt
  alias TripTally.Accounts.User
  alias TripTally.Expenses.Expense
  alias TripTally.Trips.Locations
  alias TripTally.Trips.Trip

  defp unique_user_email, do: "user#{System.unique_integer()}@example.com"
  defp valid_user_password, do: "Password1!"
  defp hashed_user_password, do: "Password1!" |> Bcrypt.hash_pwd_salt()

  def user_factory do
    %User{
      email: unique_user_email(),
      password: valid_user_password(),
      hashed_password: hashed_user_password(),
      country: "United States",
      default_currency_code: "USD",
      username: "Test User"
    }
  end

  def location_factory do
    %Locations{
      country_code: "US",
      city_name: "New York",
      user_id: build(:user).id
    }
  end

  def trip_factory(attrs \\ %{}) do
    location = find_or_create_location(attrs[:location] || %{})

    %Trip{
      transport_type: "Bus",
      planned_cost: 100.0,
      date_from: ~D[2024-01-01],
      date_to: ~D[2024-01-05],
      user_id: build(:user).id,
      location: location
    }
    |> Map.merge(attrs)
  end

  def expense_factory do
    %Expense{
      name: "Test Expense",
      date: ~D[2024-01-15],
      price: Money.new(1000, :USD),
      trip_id: build(:trip).id,
      user_id: build(:user).id
    }
  end

  defp find_or_create_location(attrs) do
    city_name = Map.get(attrs, :city_name, "New York")
    country_code = Map.get(attrs, :country_code, "US")

    TripTally.Repo.get_by(Locations, city_name: city_name, country_code: country_code) ||
      insert(:location, city_name: city_name, country_code: country_code)
  end
end
