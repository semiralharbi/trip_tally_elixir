defmodule TripTallyWeb.Trips.TripsJSON do
  alias TripTally.Trips.Trips

  @doc """
  Renders a list of trips.
  """
  def index(%{trips: trips}) do
    %{trips: Enum.map(trips, &data(&1))}
  end

  @doc """
  Renders a single trips.
  """
  def show(%{trip: trip}) do
    %{trip: data(trip)}
  end

  defp data(%Trips{} = trip) do
    %{
      trip_id: trip.id,
      date_to: trip.date_to,
      date_from: trip.date_from,
      user_id: trip.user_id,
      planned_cost: trip.planned_cost,
      transport_type: trip.transport_type,
      city_name: trip.location.city_name,
      country_code: trip.location.country_code,
      location_id: trip.location_id
    }
  end
end
