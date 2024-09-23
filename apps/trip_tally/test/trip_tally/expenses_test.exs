defmodule TripTally.ExpensesTest do
  use TripTally.DataCase

  alias TripTally.Expenses

  @invalid_user_id "123e4567-e89b-12d3-a456-426614174000"
  @invalid_expense_id "123e4567-e89b-12d3-a456-426614174999"

  setup do
    user = insert(:user)
    trip = insert(:trip, user_id: user.id)
    category = insert(:category)

    {:ok, user: user, trip: trip, category: category}
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
      assert length(Expenses.get_all_expense_categories()) > 0
    end
  end

  describe "create" do
    test "create/1 creates an expense successfully", %{category: %{id: category_id}} do
      attrs =
        string_params_for(:expense)
        |> merge_attributes(%{
          "currency" => "USD",
          "amount" => 12.05,
          "category_id" => category_id
        })
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

    test "update/3 updates an expense category", %{
      user: user,
      trip: trip,
      category: %{id: category_id}
    } do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      new_attrs = %{category_id: category_id}

      assert {:ok, %{category_id: ^category_id}} =
               Expenses.update(expense.id, user.id, new_attrs)
    end

    test "fails to update an expense with wrong category", %{user: user, trip: trip} do
      expense = insert(:expense, %{user_id: user.id, trip_id: trip.id})

      new_attrs = %{category_id: UUID.uuid1()}
      assert {:error, changeset} = Expenses.update(expense.id, user.id, new_attrs)
      assert %{category_id: ["does not exist"]} = errors_on(changeset)
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

  describe "create_multiple" do
    test "create_multiple/1 creates multiple expenses successfully", %{
      user: user,
      trip: trip,
      category: %{id: category_id}
    } do
      expenses_attrs = [
        %{
          "name" => "Hotel",
          "currency" => "USD",
          "amount" => 200.0,
          "category_id" => category_id,
          "date" => ~D[2024-04-30],
          "trip_id" => trip.id,
          "user_id" => user.id
        },
        %{
          "name" => "Flight",
          "currency" => "USD",
          "amount" => 500.0,
          "category_id" => category_id,
          "date" => ~D[2024-04-29],
          "trip_id" => trip.id,
          "user_id" => user.id
        }
      ]

      assert {:ok, _result} = Expenses.create_multiple(expenses_attrs)

      expenses = Expenses.get_all_user_expenses(user.id)
      assert length(expenses) == 2
      assert Enum.any?(expenses, fn e -> e.name == "Hotel" end)
      assert Enum.any?(expenses, fn e -> e.name == "Flight" end)
    end

    test "create_multiple/1 returns an error when one expense is invalid", %{
      user: user,
      trip: trip,
      category: %{id: category_id}
    } do
      expenses_attrs = [
        %{
          "name" => "Hotel",
          "currency" => "USD",
          "amount" => 200.0,
          "category_id" => category_id,
          "date" => ~D[2024-04-30],
          "trip_id" => trip.id,
          "user_id" => user.id
        },
        %{
          "name" => "",
          "currency" => "USD",
          "amount" => nil,
          "category_id" => category_id,
          "date" => ~D[2024-04-29],
          "trip_id" => trip.id,
          "user_id" => user.id
        }
      ]

      assert {:error, changeset} =
               Expenses.create_multiple(expenses_attrs)

      assert %{price: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
