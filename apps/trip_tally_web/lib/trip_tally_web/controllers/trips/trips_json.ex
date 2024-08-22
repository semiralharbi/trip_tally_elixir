defmodule TripTallyWeb.Trips.TripsJSON do
  alias TripTally.Trips.Trip

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
    %{trip: trip}
  end

  defp data(%Trip{} = trip) do
    trip
  end
end
