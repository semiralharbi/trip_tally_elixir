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
  Purpose: Retrieves a specific trip by its ID, ensuring that it belongs to the logged-in user.

  Endpoint: GET /api/trips/:id

  Parameters:
    - trip_id (Binary ID): ID of the trip to fetch.

  Returns: JSON representation of the trip if found and belongs to the user; otherwise, a forbidden status.
  """
  def show(conn, %{"id" => trip_id}, user) do
    with {:ok, trip} <- fetch_trip_for_user(trip_id, user) do
      render(conn, :show, trip: trip)
    end
  end

  @doc """
  Purpose: Updates an existing trip's details, validating that the trip belongs to the logged-in user.

  Endpoint: PUT /api/trips/:trip_id

  Parameters:
    - trip_id (Binary ID): ID of the trip to update.
    - trip_params (Map): Contains any of the following fields that might be updated:
      - transport_type (String)
      - planned_cost (Float)
      - date_from (Date)
      - date_to (Date)
      - country_code (String): Country code of the trip location.
      - city_name (String): City name of the trip location.

  Returns: JSON representation of the updated trip if successful; otherwise, an error message.
  """
  def update(conn, params, user) do
    with {:ok, trip} <- fetch_trip_for_user(params["id"], user),
         {:ok, updated_trip} <-
           TripTally.Trips.update(trip, params |> Map.put("user_id", user.id)) do
      render(conn, :show, trip: updated_trip)
    else
      error -> error
    end
  end

  @doc """
  Purpose: Deletes a specific trip, ensuring that the trip belongs to the logged-in user.

  Endpoint: DELETE /api/trips/:id

  Parameters:
  - id (Binary ID): ID of the trip to delete.

  Returns: No content on successful deletion; otherwise, an error message.
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
  Purpose: Checks if there is a trip starting today for the logged-in user.

  Endpoint: GET /api/trips/today

  Parameters: None required. The user ID is obtained from the session.

  Returns: JSON array of trips starting today, or an empty array if none found.
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
