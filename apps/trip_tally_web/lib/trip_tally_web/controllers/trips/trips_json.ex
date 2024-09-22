defmodule TripTallyWeb.Trips.TripsJSON do
  alias TripTally.Money
  alias TripTally.Trips.Trip
  alias Money
  alias Decimal

  @doc """
  Renders a list of trips.
  """
  def index(%{trips: trips}) do
    trips = Money.convert_to_decimal_amount(trips)
    %{trips: trips}
  end

  @doc """
  Renders a single trip.
  """
  def show(%{trip: %Trip{} = trip}) do
    trip = Money.convert_to_decimal_amount(trip)
    %{trip: trip}
  end
end
