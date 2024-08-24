defmodule TripTallyWeb.Trips.TripsJSON do
  alias TripTally.Trips.Trip

  @doc """
  Renders a list of trips.
  """
  def index(%{trips: trips}) do
    trips = Enum.map(trips, &convert_planned_cost_amount/1)
    %{trips: trips}
  end

  @doc """
  Renders a single trip.
  """
  def show(%{trip: %Trip{} = trip}) do
    trip = convert_planned_cost_amount(trip)
    %{trip: trip}
  end

  defp convert_planned_cost_amount(trip) do
    Map.update(trip, :planned_cost, 0, fn planned_cost ->
      Map.update(planned_cost, :amount, 0, fn amount ->
        amount / 100.0
      end)
    end)
  end
end
