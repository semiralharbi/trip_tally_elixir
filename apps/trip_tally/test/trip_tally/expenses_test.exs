defmodule TripTally.ExpensesTest do
  alias TripTally.Expenses.Expense
  use TripTally.DataCase

  alias TripTally.Expenses

  @invalid_user_id "123e4567-e89b-12d3-a456-426614174000"
  @invalid_expense_id "123e4567-e89b-12d3-a456-426614174999"
  setup do
    user = insert(:user)
    trip = insert(:trip, user_id: user.id)

    {:ok, user: user, trip: trip}
  end

  describe "fetch" do
    test "get_all_user_expenses returns expenses for a given user", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      expenses = Expenses.get_all_user_expenses(user.id)
      assert length(expenses) > 0
      assert Enum.any?(expenses, fn e -> e.id == expense.id end)
    end

    test "get_all_user_expenses returns empty list for invalid user" do
      assert [] == Expenses.get_all_user_expenses(@invalid_user_id)
    end

    test "get_all_expenses_categories returns the full list of categories" do
      assert Ecto.Enum.values(Expense, :category) == Expenses.get_all_expense_categories()
    end
  end

  describe "create" do
    test "create/1 creates an expense successfully" do
      attrs =
        string_params_for(:expense)
        |> merge_attributes(%{"currency" => "USD", "amount" => 12.05})
        |> Map.delete("price")

      assert {:ok,
              %{
                name: "Test Expense",
                price: %{amount: 1205, currency: :USD},
                date: ~D[2024-01-15]
              }} =
               Expenses.create(attrs)
    end

    test "create/1 returns changeset error with invalid data", %{user: user, trip: trip} do
      invalid_attrs = %{
        "name" => nil,
        "date" => nil,
        "trip_id" => trip.id,
        "user_id" => user.id
      }

      assert {:error, changeset} = Expenses.create(invalid_attrs)

      assert %{
               date: ["can't be blank"],
               price: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "update" do
    test "update/3 updates an expense by id", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      new_attrs = %{price: Money.new(20_000, :USD)}

      assert {:ok, %{price: %{amount: 20_000, currency: :USD}}} =
               Expenses.update(expense.id, user.id, new_attrs)
    end

    test "update/3 updates an expense category", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      new_attrs = %{category: :activities}

      assert {:ok, %{category: :activities}} =
               Expenses.update(expense.id, user.id, new_attrs)
    end

    test "fails to update an expense with wrong category", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      new_attrs = %{category: :wrong_category}
      assert {:error, changset} = Expenses.update(expense.id, user.id, new_attrs)
      assert %{category: ["is invalid"]} = errors_on(changset)
    end
  end

  describe "delete" do
    test "delete/1 deletes an expense by id", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      assert {:ok, _} = Expenses.delete(expense.id, user.id)
      assert {:error, :not_found} == Expenses.get_expense(expense.id, user.id)
    end
  end

  test "attempt to delete non-existent expense raises error", %{user: user} do
    assert {:error, :not_found} = Expenses.delete(@invalid_expense_id, user.id)
  end
end
