defmodule TripTallyWeb.Trips.TripsController do
  use TripTallyWeb, :controller

  alias TripTally.Trips.Trips

  action_fallback TripTallyWeb.FallbackController

  @doc """
  Purpose: Fetches all trips created by the currently logged-in user.

  Endpoint: GET /api/trips/trips

  Parameters: None required. The user ID is obtained from the session.

  Returns: JSON array of created trips for the logged-in user.
  """
  def index(conn, _params) do
    user_id = conn.assigns.current_user.id
    trips = TripTally.Trips.get_trips_by_user(user_id)
    render(conn, :index, trips: trips)
  end

  @doc """
  Purpose: Creates a new trip with location details, associating it with the logged-in user.

  Endpoint: POST /api/trips/trips

  Parameters:

  transport_type (String): Type of transportation used for the trip.
  planned_cost (Integer): Estimated cost of the trip.
  date_from (Date): Start date of the trip.
  date_to (Date): End date of the trip.
  country_code (String): Country code of the trip location
  city_name (String): City name of the trip location

  Returns: JSON representation of the created trip, including its unique identifier.
  """
  def create(conn, params) do
    user_id = conn.assigns.current_user.id
    combined_params = Map.put(params, "user_id", user_id)

    case TripTally.Trips.create_trip_with_location(combined_params) do
      {:ok, %Trips{} = trip} ->
        conn
        |> put_status(:created)
        |> render(:show, trip: trip)

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, :forbidden}
    end
  end

  @doc """
  Purpose: Retrieves a specific trip by its ID, ensuring that it belongs to the logged-in user.

  Endpoint: GET /api/trips/trips/:trip_id

  Parameters:

  trip_id (Binary ID): ID of the trip to fetch.

  Returns: JSON representation of the trip if found and belongs to the user; otherwise, a forbidden status.
  """
  def show(conn, %{"id" => trip_id}) do
    case TripTally.Trips.fetch_trip_by_id(trip_id) do
      {:ok, trip} when trip.user_id == conn.assigns.current_user.id ->
        render(conn, :show, trip: trip)

      {:ok, _} ->
        {:error, :forbidden}

      {:error, _reason} ->
        {:error, :not_found}
    end
  end

  @doc """
  Purpose: Updates an existing trip's details, validating that the trip belongs to the logged-in user.

  Endpoint: PUT /api/trips/:trip_id

  Parameters:

  trip_id (Binary ID): ID of the trip to update.
  trip_params (Map): Contains any of the following fields that might be updated:
  transport_type (String)
  planned_cost (Integer)
  date_from (Date)
  date_to (Date)
  country_code (String): Country code of the trip location
  city_name (String): City name of the trip location

  Returns: JSON representation of the updated trip if successful; otherwise, an error message.
  """
  def update(conn, %{"id" => trip_id, "trip_params" => trip_params}) do
    case TripTally.Trips.fetch_trip_by_id(trip_id) do
      {:ok, trip} when trip.user_id == conn.assigns.current_user.id ->
        case TripTally.Trips.update(trip.id, trip_params) do
          {:ok, updated_trip} ->
            render(conn, :show, trip: updated_trip)

          {:error, changeset} ->
            {:error, changeset}
        end

      {:ok, _} ->
        {:error, :forbidden}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  @doc """
  Purpose: Deletes a specific trip, ensuring that the trip belongs to the logged-in user.

  Endpoint: DELETE /api/trips/trips/:id

  Parameters:

  id (Binary ID): ID of the trip to delete.

  Returns: No content on successful deletion; otherwise, an error message.
  """
  def delete(conn, %{"id" => trip_id}) do
    trip = TripTally.Trips.fetch_trip_by_id(trip_id)

    case trip do
      {:ok, %Trips{} = trip} when trip.user_id == conn.assigns.current_user.id ->
        case TripTally.Trips.delete(trip_id) do
          {:ok, %Trips{}} ->
            send_resp(conn, :no_content, "")

          {:error, _reason} ->
            {:error, :not_found}
        end

      _ ->
        {:error, :forbidden}
    end
  end
end
