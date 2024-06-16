defmodule TripTallyWeb.ExpenseControllerTest do
  use TripTallyWeb.ConnCase, async: true

  alias TripTally.TripsFixtures
  alias TripTally.ExpensesFixtures

  setup :register_and_log_in_user

  describe "index" do
    test "lists all expenses for a user", %{conn: conn, user: %{id: user_id}} do
      ExpensesFixtures.create_multiple_expenses_for_trip(user_id)

      conn = get(conn, "/api/expenses")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 5
    end

    test "lists expenses for a specific trip", %{conn: conn, user: %{id: user_id}} do
      [{:ok, %{id: expense_id, trip_id: trip_id}} | _rest] =
        ExpensesFixtures.create_multiple_expenses_for_trip(user_id)

      conn = get(conn, "/api/expenses?trip_id=#{trip_id}")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 5
      assert Enum.any?(expenses, fn expense -> expense["id"] == expense_id end)
    end
  end

  describe "create" do
    test "creates and renders expense when data is valid", %{conn: conn, user: %{id: user_id}} do
      {:ok, trip} = TripsFixtures.trips_fixture(%{"user_id" => user_id})

      trip_id = trip.id

      attrs = %{
        "name" => "Hotel",
        "amount" => 10000,
        "currency" => "USD",
        "date" => ~D[2024-04-30],
        "trip_id" => trip_id
      }

      conn = post(conn, "/api/expenses", attrs)

      assert %{
               "trip_id" => ^trip_id,
               "user_id" => ^user_id,
               "name" => "Hotel",
               "amount" => 10000,
               "currency" => "USD",
               "date" => "2024-04-30"
             } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn, user: %{id: user_id}} do
      {:ok, _trip} = TripsFixtures.trips_fixture(%{"user_id" => user_id})

      invalid_attrs = %{"name" => "", "amount" => nil, "currency" => ""}
      conn = post(conn, "/api/expenses", invalid_attrs)

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
    test "renders expense when found", %{conn: conn, user: %{id: user_id}} do
      {:ok, %{id: expense_id}} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Lunch",
          "amount" => 1500,
          "currency" => "USD",
          "user_id" => user_id
        })

      conn = get(conn, "/api/expenses/#{expense_id}")

      assert %{
               "name" => "Lunch",
               "currency" => "USD",
               "amount" => 1500,
               "user_id" => ^user_id,
               "id" => ^expense_id
             } = json_response(conn, 200)
    end

    test "renders not found when expense does not exist", %{conn: conn} do
      conn = get(conn, "/api/expenses/#{UUID.uuid4()}")

      assert "Not found" == response(conn, 404)
    end
  end

  describe "update" do
    test "updates and renders expense when data is valid", %{conn: conn, user: %{id: user_id}} do
      {:ok, %{id: expense_id}} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Breakfast",
          "amount" => 2000,
          "currency" => "USD",
          "user_id" => user_id
        })

      update_attrs = %{"expense" => %{"name" => "Updated Breakfast"}}
      conn = put(conn, "/api/expenses/#{expense_id}", update_attrs)

      assert %{
               "name" => "Updated Breakfast",
               "currency" => "USD",
               "amount" => 2000,
               "user_id" => ^user_id,
               "id" => ^expense_id
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: %{id: user_id}} do
      {:ok, %{id: expense_id}} = ExpensesFixtures.expense_fixture(%{"user_id" => user_id})

      invalid_attrs = %{"expense" => %{"currency" => "USD", "amount" => nil}}

      conn = put(conn, "/api/expenses/#{expense_id}", invalid_attrs)

      assert %{"errors" => %{"price" => ["is invalid"]}} = json_response(conn, 422)
    end
  end

  describe "delete" do
    test "deletes expense", %{conn: conn, user: %{id: user_id}} do
      {:ok, %{id: expense_id}} =
        ExpensesFixtures.expense_fixture(%{
          "name" => "Dessert",
          "amount" => 500,
          "currency" => "USD",
          "user_id" => user_id
        })

      conn = delete(conn, "/api/expenses/#{expense_id}")
      assert response(conn, 204)

      conn = get(conn, "/api/expenses/#{expense_id}")
      assert response(conn, 404)
    end
  end
end
