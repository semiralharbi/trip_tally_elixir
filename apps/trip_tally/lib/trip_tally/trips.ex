defmodule TripTally.Trips do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias TripTally.Expenses
  alias TripTally.Locations
  alias TripTally.Money
  alias TripTally.Repo
  alias TripTally.Trips.Trip

  @doc """
  Fetch trips starting today for a given user.
  """
  def fetch_trip_starting_today(user_id) do
    today = Date.utc_today()

    Trip
    |> where([t], t.user_id == ^user_id)
    |> where([t], t.date_from == ^today)
    |> where([t], t.status == :planned)
    |> Repo.one()
    |> Repo.preload([:location, :expenses])
    |> case do
      nil -> {:error, :not_found}
      trip -> {:ok, trip}
    end
  end

  @doc """
  Creates a trip with a location obtained via `create_or_fetch_location`.
  """
  def create_trip_with_location(attrs) do
    attrs = Money.create_price(attrs, "planned_cost")

    Multi.new()
    |> Multi.run(:location, fn _repo, _changes -> Locations.create_or_fetch_location(attrs) end)
    |> Multi.run(:trip, fn _repo, %{location: location} -> create_trip(attrs, location) end)
    |> Multi.run(:expenses, fn _repo, %{trip: trip} -> create_expenses(attrs, trip) end)
    |> Multi.run(:preload_trip, fn _repo, %{trip: trip} -> preload_trip(trip) end)
    |> Repo.transaction()
    |> handle_transaction_result()
  end

  defp create_expenses(attrs, trip) do
    expenses = attrs["expenses"] || []
    expenses_with_trip = Enum.map(expenses, &add_trip_and_user(&1, trip))

    case Expenses.create_multiple(expenses_with_trip) do
      {:ok, expenses} -> {:ok, expenses}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp add_trip_and_user(expense, trip) do
    expense
    |> Map.put("trip_id", trip.id)
    |> Map.put("user_id", trip.user_id)
  end

  defp preload_trip(trip) do
    {:ok, Repo.preload(trip, [:location, :expenses]) |> Map.drop([:location_id])}
  end

  defp handle_transaction_result({:ok, %{preload_trip: trip}}), do: {:ok, trip}
  defp handle_transaction_result({:error, _, changeset, _}), do: {:error, changeset}

  defp create_trip(attrs, location) do
    attrs
    |> Map.put("location_id", location.id)
    |> create_trip()
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
      |> preload([:location, :expenses])

    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      trip -> {:ok, trip}
    end
  end

  @doc """
  Fetch all trips by user_id.
  """
  def get_trips_by_user(user_id) do
    query =
      Trip
      |> where([t], t.user_id == ^user_id)
      |> preload([:location, :expenses])

    Repo.all(query)
  end

  @doc """
  Update a trip by id and replace the attrs.
  """
  def update(id, attrs) do
    with {:ok, trip} <- fetch_trip_by_id(id),
         updated_attrs <- TripTally.Money.maybe_update_price(trip, attrs) do
      trip
      |> Trip.changeset_update(updated_attrs)
      |> Repo.update()
      |> case do
        {:ok, trip} ->
          trip = Repo.preload(trip, [:location, :expenses])
          {:ok, trip}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      _ -> {:error, :not_found}
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
