defmodule TripTally.Trips do
  @moduledoc false

  import Ecto.Query, warn: false

  alias TripTally.Locations
  alias TripTally.Repo
  alias TripTally.Trips.Trip

  @doc """
  Fetch trips starting today for a given user.
  """
  def fetch_trip_starting_today(user_id) do
    today = Date.utc_today()

    Trip
    |> where([t], t.user_id == ^user_id and t.date_from == ^today)
    |> Repo.one()
    |> Repo.preload(:location)
  end

  @doc """
  Creates a trip with a location obtained via `create_or_fetch_location`.
  """
  def create_trip_with_location(attrs) do
    with {:ok, location} <- Locations.create_or_fetch_location(attrs),
         {:ok, trip} <-
           create_trip(
             Map.merge(attrs, %{
               "location_id" => location.id
             })
           ) do
      {:ok, trip |> Repo.preload(:location)}
    else
      error -> error
    end
  end

  defp create_trip(attrs) do
    %Trip{}
    |> Trip.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetch a trip by id.
  """
  def fetch_trip_by_id(id) do
    query =
      Trip
      |> where([t], t.id == ^id)
      |> preload(:location)

    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      trip -> {:ok, trip}
    end
  end

  @doc """
  Fetch all trips by user_id.
  """
  def get_trips_by_user(user_id, preload \\ []) do
    preload_list = [:location | preload]

    query =
      Trip
      |> where([t], t.user_id == ^user_id)
      |> preload(^preload_list)

    Repo.all(query)
  end

  @doc """
  Update a trip by id and replace the attrs.
  """
  def update(id, attrs) do
    case Repo.get!(Trip, id)
         |> Trip.changeset_update(attrs)
         |> Repo.update() do
      {:ok, trip} ->
        trip = Repo.preload(trip, :location)
        {:ok, trip}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Delete a trip by id.
  """
  def delete(id) do
    case Repo.get(Trip, id) do
      nil -> {:error, :not_found}
      trip -> Repo.delete(trip)
    end
  end
end
