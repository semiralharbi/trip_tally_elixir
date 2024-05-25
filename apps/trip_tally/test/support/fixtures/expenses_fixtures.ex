defmodule TripTally.ExpensesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TripTally.Expenses` context.
  """
  alias TripTally.Expenses
  alias TripTally.TripsFixtures

  @doc """
  Generate a expense.
  """
  def expense_fixture(attrs \\ %{}) do
    trip_attrs = %{"user_id" => attrs["user_id"]}

    {:ok, trip} = TripsFixtures.trips_fixture(trip_attrs)

    default_attrs = %{
      "name" => "some name",
      "date" => ~D[2024-04-30],
      "currency" => "USD",
      "amount" => "12000",
      "trip_id" => trip.id,
      "user_id" => trip.user_id
    }

    merged_attrs = Map.merge(default_attrs, Map.drop(attrs, ["user_id", "trip_id"]))

    create_expense(merged_attrs)
  end

  def create_multiple_expenses_for_trip(user_id) do
    trip_attrs = %{"user_id" => user_id}

    {:ok, trip} =
      TripsFixtures.trips_fixture(trip_attrs)

    Enum.map(1..5, fn x ->
      expense_attrs = %{
        "name" => "Expense #{x}",
        "date" => ~D[2024-04-30],
        "currency" => "USD",
        "amount" => "12000",
        "trip_id" => trip.id,
        "user_id" => user_id
      }

      create_expense(expense_attrs)
    end)
  end

  defp create_expense(attrs) do
    case Expenses.create(attrs) do
      {:ok, expense} -> {:ok, expense}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
