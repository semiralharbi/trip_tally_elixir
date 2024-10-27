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
    |> calculate_total_expenses()
    |> Repo.one()
    |> repo_preload_trip()
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
    |> Multi.run(:trip_with_total_expenses, fn _repo, %{trip: trip} ->
      calculate_total_expenses_for_trip(trip.id)
    end)
    |> Multi.run(:preloaded_trip, fn _repo,
                                     %{trip_with_total_expenses: trip_with_total_expenses} ->
      {:ok, repo_preload_trip(trip_with_total_expenses)}
    end)
    |> Repo.transaction()
    |> handle_transaction_result()
  end

  defp create_expenses(attrs, trip) do
    attrs
    |> Map.get("expenses", [])
    |> Enum.map(&add_trip_and_user(&1, trip))
    |> Expenses.create_multiple()
    |> case do
      {:ok, expenses} -> {:ok, expenses}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp calculate_total_expenses_for_trip(trip_id) do
    trip =
      Trip
      |> where([t], t.id == ^trip_id)
      |> calculate_total_expenses()
      |> Repo.one()

    {:ok, trip}
  end

  defp add_trip_and_user(expense_params, %Trip{id: trip_id, user_id: user_id}) do
    expense_params
    |> Map.put("trip_id", trip_id)
    |> Map.put("user_id", user_id)
  end

  defp handle_transaction_result({:ok, %{preloaded_trip: trip}}),
    do: {:ok, trip}

  defp handle_transaction_result({:error, _, changeset, _}), do: {:error, changeset}

  defp create_trip(attrs, nil) do
    attrs
    |> create_trip()
  end

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
      |> join(:left, [t], e in assoc(t, :expenses))
      |> group_by([t], t.id)
      |> preload([t, e], [:location, expenses: [:category]])
      |> select_merge([t, e], %{
        total_expenses: fragment("COALESCE(ROUND(SUM((?).amount) / 100, 2), 0.0)", e.price)
      })

    case Repo.one(query) do
      nil -> {:error, :not_found}
      trip -> {:ok, trip}
    end
  end

  @doc """
  Fetch all trips by user_id.
  """
  def get_trips_by_user(user_id) do
    Trip
    |> where([t], t.user_id == ^user_id)
    |> calculate_total_expenses()
    |> order_by([t], asc: t.date_from, asc: t.date_to)
    |> Repo.all()
  end

  @doc """
  Update a trip by id and replace the attrs.
  """
  def update(trip, attrs) do
    updated_attrs =
      attrs
      |> fetch_location_id()
      |> Money.maybe_update_price(trip)

    trip
    |> Trip.changeset_update(updated_attrs)
    |> Repo.update()
    |> case do
      {:ok, trip} ->
        {:ok, repo_preload_trip(trip)}

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

  defp repo_preload_trip(trip) do
    Repo.preload(trip, [:location, expenses: [:category]])
  end

  defp calculate_total_expenses(query) do
    query
    |> join(:left, [t], e in assoc(t, :expenses))
    |> group_by([t], t.id)
    |> preload([t, e], [:location, expenses: [:category]])
    |> select_merge([t, e], %{
      total_expenses: fragment("COALESCE(ROUND(SUM((?).amount) / 100, 2), 0.0)", e.price)
    })
  end

  defp fetch_location_id(attrs) do
    case TripTally.Locations.create_or_fetch_location(attrs) do
      {:ok, location} -> Map.put(attrs, "location_id", location.id)
      _ -> attrs
    end
  end
end
