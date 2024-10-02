defmodule TripTallyWeb.Trips.TripsController do
  use TripTallyWeb.AuthController

  alias TripTally.Trips.Trip

  @doc """
  Purpose: Fetches all trips created by the currently logged-in user.

  Endpoint: GET /api/trips

  Parameters: None required. The user ID is obtained from the session.

  Returns: JSON array of created trips for the logged-in user.
  """
  def index(conn, _params, user) do
    trips = TripTally.Trips.get_trips_by_user(user.id)
    render(conn, :index, trips: trips)
  end

  @doc """
  Purpose: Creates a new trip with location details, associating it with the logged-in user.

  Endpoint: POST /api/trips

  Parameters:
  - transport_type (String): Type of transportation used for the trip.
  - planned_cost (Float): Estimated cost of the trip.
  - date_from (Date): Start date of the trip.
  - date_to (Date): End date of the trip.
  - country_code (String): Country code of the trip location.
  - city_name (String): City name of the trip location.

  Returns: JSON representation of the created trip, including its unique identifier.
  """
  def create(conn, params, user) do
    combined_params = Map.put(params, "user_id", user.id)

    case TripTally.Trips.create_trip_with_location(combined_params) do
      {:ok, %Trip{} = trip} ->
        conn
        |> put_status(:created)
        |> render(:show, trip: trip)

      error ->
        error
    end
  end

  @doc """
  Retrieves a specific trip by its ID, ensuring that it belongs to the logged-in user.
  """
  def show(conn, %{"id" => trip_id}, user) do
    with {:ok, trip} <- fetch_trip_for_user(trip_id, user) do
      render(conn, :show, trip: trip)
    end
  end

  @doc """
  Updates an existing trip's details, ensuring it belongs to the logged-in user.
  """
  def update(conn, %{"id" => trip_id, "trip_params" => trip_params}, user) do
    with {:ok, trip} <- fetch_trip_for_user(trip_id, user),
         {:ok, updated_trip} <- TripTally.Trips.update(trip, trip_params) do
      render(conn, :show, trip: updated_trip)
    else
      error -> error
    end
  end

  @doc """
  Deletes a specific trip, ensuring it belongs to the logged-in user.
  """
  def delete(conn, %{"id" => trip_id}, user) do
    with {:ok, trip} <- fetch_trip_for_user(trip_id, user),
         {:ok, %Trip{}} <- TripTally.Trips.delete(trip.id) do
      send_resp(conn, :no_content, "")
    else
      error -> error
    end
  end

  @doc """
  Checks if there is a trip starting today for the logged-in user.
  """
  def today(conn, _params, user) do
    case TripTally.Trips.fetch_trip_starting_today(user.id) do
      {:ok, trip} -> render(conn, :show, trip: trip)
      error -> error
    end
  end

  defp fetch_trip_for_user(trip_id, user) do
    case TripTally.Trips.fetch_trip_by_id(trip_id) do
      {:ok, trip} when trip.user_id == user.id -> {:ok, trip}
      {:ok, _} -> {:error, :forbidden}
      {:error, _} -> {:error, :not_found}
    end
  end
end
