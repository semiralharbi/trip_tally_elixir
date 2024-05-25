defmodule TripTallyWeb.ExpenseControllerTest do
  use TripTallyWeb.ConnCase, async: true

  alias TripTally.TripsFixtures
  alias TripTally.ExpensesFixtures

  setup :register_and_log_in_user

  describe "index" do
    test "lists all expenses for a user", %{conn: conn, user: user} do
      ExpensesFixtures.create_multiple_expenses_for_trip(user.id)

      conn = get(conn, "/api/expenses")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 5
    end

    test "lists expenses for a specific trip", %{conn: conn, user: user} do
      [{:ok, expense1} | _rest] = ExpensesFixtures.create_multiple_expenses_for_trip(user.id)

      trip_id = expense1.trip_id

      conn = get(conn, "/api/expenses?trip_id=#{trip_id}")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 5
    end
  end

  describe "create" do
    test "creates and renders expense when data is valid", %{conn: conn, user: user} do
      {:ok, trip} = TripsFixtures.trips_fixture(%{"user_id" => user.id})

      attrs = %{
        "name" => "Hotel",
        "amount" => 10000,
        "currency" => "USD",
        "date" => ~D[2024-04-30],
        "trip_id" => trip.id
      }

      conn = post(conn, "/api/expenses", expense: attrs)

      assert %{
               "name" => "Hotel",
               "amount" => 10000,
               "currency" => "USD",
               "date" => "2024-04-30"
             } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      {:ok, _trip} = TripsFixtures.trips_fixture(%{"user_id" => user.id})

      invalid_attrs = %{"name" => "", "amount" => nil, "currency" => ""}
      conn = post(conn, "/api/expenses", expense: invalid_attrs)

      assert %{
               "errors" => %{
                 "date" => ["can't be blank"],
                 "price" => ["can't be blank"],
                 "trip_id" => ["can't be blank"]
               }
             } = json_response(conn, 422)
    end
  end

  describe "show" do
    test "renders expense when found", %{conn: conn, user: user} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Lunch",
          "amount" => 1500,
          "currency" => "USD",
          "user_id" => user.id
        })

      conn = get(conn, "/api/expenses/#{expense.id}")

      assert %{"name" => "Lunch"} = json_response(conn, 200)
    end

    test "renders not found when expense does not exist", %{conn: conn} do
      conn = get(conn, "/api/expenses/#{UUID.uuid4()}")

      assert "Not found" == response(conn, 404)
    end
  end

  describe "update" do
    test "updates and renders expense when data is valid", %{conn: conn, user: user} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Breakfast",
          "amount" => 2000,
          "currency" => "USD",
          "user_id" => user.id
        })

      update_attrs = %{"expense" => %{"name" => "Updated Breakfast"}}
      conn = put(conn, "/api/expenses/#{expense.id}", update_attrs)

      assert %{"name" => "Updated Breakfast"} = json_response(conn, 200)
    end

    test "renders  when data is invalid", %{conn: conn, user: user} do
      {:ok, expense} = ExpensesFixtures.expense_fixture(%{"user_id" => user.id})
      invalid_attrs = %{"expense" => %{"currency" => "None existing currency"}}
      conn = put(conn, "/api/expenses/#{expense.id}", invalid_attrs)

      assert %{"errors" => %{"price" => ["is invalid"]}} = json_response(conn, 422)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      {:ok, expense} = ExpensesFixtures.expense_fixture(%{"user_id" => user.id})
      invalid_attrs = %{"expense" => %{"currency" => "USD", "amount" => nil}}
      conn = put(conn, "/api/expenses/#{expense.id}", invalid_attrs)

      assert %{"errors" => %{"price" => ["is invalid"]}} = json_response(conn, 422)
    end
  end

  describe "delete" do
    test "deletes expense", %{conn: conn, user: user} do
      {:ok, expense} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Dessert",
          "amount" => 500,
          "currency" => "USD",
          "user_id" => user.id
        })

      conn = delete(conn, "/api/expenses/#{expense.id}")
      assert response(conn, 204)

      conn = get(conn, "/api/expenses/#{expense.id}")
      assert response(conn, 404)
    end
  end
end
