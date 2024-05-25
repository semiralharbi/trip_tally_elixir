defmodule TripTally.TripsFixtures do
  alias TripTally.AccountsFixtures
  alias TripTally.Trips

  @moduledoc """
  This module defines test helpers for creating entities via the `TripTally.Trips` context.
  """

  @doc """
  Generate a `Trips` record with default data or overridden with provided attributes.
  """
  def trips_fixture(attrs \\ %{}) do
    user_id = AccountsFixtures.user_fixture().id

    default_attrs = %{
      "transport_type" => "Bus",
      "planned_cost" => 100,
      "date_from" => ~D[2024-01-01],
      "date_to" => ~D[2024-01-05],
      "user_id" => user_id,
      "country_code" => "US",
      "city_name" => "New York"
    }

    merged_attrs = Map.merge(default_attrs, attrs)

    case Trips.create_trip_with_location(merged_attrs) do
      {:ok, trip} -> {:ok, trip}
      {:error, _changeset} -> raise "Failed to create a trip fixture"
    end
  end
end
