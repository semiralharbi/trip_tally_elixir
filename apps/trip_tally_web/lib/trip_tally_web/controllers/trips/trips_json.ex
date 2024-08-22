defmodule TripTallyWeb.Trips.TripsJSON do
  alias TripTally.Trips.Trip

  @doc """
  Renders a list of trips.
  """
  def index(%{trips: trips}) do
    %{trips: trips}
  end

  @doc """
  Renders a single trips.
  """
  def show(%{trip: %Trip{} = trip}) do
    %{trip: trip}
  end
end
