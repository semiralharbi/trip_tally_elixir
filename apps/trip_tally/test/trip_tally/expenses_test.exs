defmodule TripTally.ExpensesTest do
  use TripTally.DataCase
  alias TripTally.Expenses
  alias TripTally.ExpensesFixtures

  @invalid_user_id "123e4567-e89b-12d3-a456-426614174000"
  @invalid_expense_id "123e4567-e89b-12d3-a456-426614174999"

  describe "Expenses management" do
    setup do
      {:ok, trip} = TripTally.TripsFixtures.trips_fixture()
      user = TripTally.AccountsFixtures.user_fixture()
      {:ok, user: user, trip: trip}
    end

    test "get_all_user_expenses returns expenses for a given user", %{user: user, trip: trip} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{"user_id" => user.id, "trip_id" => trip.id})

      expenses = Expenses.get_all_user_expenses(user.id)
      assert length(expenses) > 0
      assert Enum.any?(expenses, fn e -> e.id == expense.id end)
    end

    test "get_all_user_expenses returns empty list for invalid user" do
      assert [] == Expenses.get_all_user_expenses(@invalid_user_id)
    end

    test "create/1 creates an expense successfully", %{user: user, trip: trip} do
      user_id = user.id
      trip_id = trip.id

      attrs = %{
        "name" => "Hotel",
        "date" => ~D[2024-04-30],
        "currency" => "USD",
        "amount" => 12_050,
        "trip_id" => trip_id,
        "user_id" => user_id
      }

      assert {:ok,
              %{
                name: "Hotel",
                price: %{amount: 12_050, currency: :USD},
                date: ~D[2024-04-30],
                trip_id: ^trip_id,
                user_id: ^user_id
              }} =
               Expenses.create(attrs)
    end

    test "update/3 updates an expense by id", %{user: user, trip: trip} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{"user_id" => user.id, "trip_id" => trip.id})

      new_attrs = %{price: Money.new(20_000, :USD)}

      assert {:ok, %{price: %{amount: 20_000, currency: :USD}}} =
               Expenses.update(expense.id, user.id, new_attrs)
    end

    test "delete/1 deletes an expense by id", %{user: user, trip: trip} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{"user_id" => user.id, "trip_id" => trip.id})

      assert {:ok, _} = Expenses.delete(expense.id, user.id)
      assert {:error, :not_found} == Expenses.get_expense(expense.id, user.id)
    end

    test "attempt to delete non-existent expense raises error", %{user: user} do
      assert {:error, :not_found} = Expenses.delete(@invalid_expense_id, user.id)
    end
  end
end
