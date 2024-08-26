defmodule TripTallyWeb.ExpenseControllerTest do
  use TripTallyWeb.ConnCase, async: true

  setup :register_and_log_in_user

  describe "index" do
    setup %{user: %{id: user_id}} do
      trip = insert(:trip, user_id: user_id)
      trip2 = insert(:trip, user_id: user_id)
      insert(:expense, trip_id: trip.id, user_id: user_id)
      insert(:expense, trip_id: trip.id, user_id: user_id)
      insert(:expense, trip_id: trip.id, user_id: user_id)
      insert(:expense, trip_id: trip.id, user_id: user_id)
      insert(:expense, trip_id: trip.id, user_id: user_id)
      insert(:expense, trip_id: trip2.id, user_id: user_id)
      {:ok, %{trip: trip}}
    end

    test "lists all expenses for a user", %{conn: conn} do
      conn = get(conn, "/api/expenses")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 6
    end

    test "lists expenses for a specific trip", %{conn: conn, trip: %{id: trip_id}} do
      conn = get(conn, "/api/expenses?trip_id=#{trip_id}")

      assert %{"expenses" => expenses} = json_response(conn, 200)
      assert length(expenses) == 5
    end

    test "lists all expenses categories", %{conn: conn} do
      conn = get(conn, "/api/expenses_categories")

      assert %{"categories" => categories} = json_response(conn, 200)
      assert length(categories) == 22
    end
  end

  describe "create" do
    setup %{user: %{id: user_id}} do
      trip = insert(:trip, user_id: user_id)

      {:ok, %{trip: trip}}
    end

    test "creates and renders expense when data is valid", %{
      conn: conn,
      trip: %{id: trip_id},
      user: %{id: user_id}
    } do
      attrs = %{
        "name" => "Hotel",
        "amount" => 1000.0,
        "currency" => "USD",
        "date" => ~D[2024-04-30],
        "trip_id" => trip_id
      }

      conn = post(conn, "/api/expenses", attrs)

      assert %{
               "expense" => %{
                 "trip_id" => ^trip_id,
                 "user_id" => ^user_id,
                 "name" => "Hotel",
                 "price" => %{"amount" => 1000.0, "currency" => "USD"},
                 "date" => "2024-04-30"
               }
             } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{"name" => "", "amount" => nil, "currency" => ""}
      conn = post(conn, "/api/expenses", invalid_attrs)
      response = json_response(conn, 422)

      expected_errors = [
        %{"field" => "date", "message" => "The Date cannot be blank."},
        %{"field" => "trip_id", "message" => "The Trip id cannot be blank."},
        %{"field" => "price", "message" => "The Price cannot be blank."}
      ]

      assert Enum.sort(response["errors"]) == Enum.sort(expected_errors)
    end
  end

  describe "show" do
    setup %{user: %{id: user_id}} do
      expense = insert(:expense, user_id: user_id)

      {:ok, %{expense: expense}}
    end

    test "renders expense when found", %{
      conn: conn,
      expense: %{id: expense_id},
      user: %{id: user_id}
    } do
      conn = get(conn, "/api/expenses/#{expense_id}")

      assert %{
               "expense" => %{
                 "name" => "Test Expense",
                 "price" => %{"amount" => 100.0, "currency" => "USD"},
                 "user_id" => ^user_id,
                 "id" => ^expense_id
               }
             } = json_response(conn, 200)
    end

    test "renders not found when expense does not exist", %{conn: conn} do
      conn = get(conn, "/api/expenses/#{UUID.uuid4()}")

      assert %{"errors" => "Not Found"} == json_response(conn, 404)
    end
  end

  describe "update" do
    setup %{user: %{id: user_id}} do
      trip = insert(:trip, user_id: user_id)
      expense = insert(:expense, user_id: user_id, trip_id: trip.id)

      {:ok, %{expense: expense}}
    end

    test "updates and renders expense when data is valid", %{
      conn: conn,
      user: %{id: user_id},
      expense: %{id: expense_id}
    } do
      update_attrs = %{"expense" => %{"name" => "Updated Breakfast"}}
      conn = put(conn, "/api/expenses/#{expense_id}", update_attrs)

      assert %{
               "expense" => %{
                 "name" => "Updated Breakfast",
                 "price" => %{"amount" => 100.0, "currency" => "USD"},
                 "user_id" => ^user_id,
                 "id" => ^expense_id
               }
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      expense: %{id: expense_id}
    } do
      invalid_attrs = %{"expense" => %{"currency" => "USD", "amount" => nil}}

      conn = put(conn, "/api/expenses/#{expense_id}", invalid_attrs)

      assert %{"errors" => [%{"field" => "price", "message" => "The Price is invalid."}]} =
               json_response(conn, 422)
    end
  end

  describe "delete" do
    setup %{user: %{id: user_id}} do
      expense = insert(:expense, user_id: user_id)

      {:ok, %{expense: expense}}
    end

    test "deletes expense", %{conn: conn, expense: %{id: expense_id}} do
      conn = delete(conn, "/api/expenses/#{expense_id}")
      assert response(conn, 204)

      conn = get(conn, "/api/expenses/#{expense_id}")
      assert response(conn, 404)
    end
  end
end
