defmodule TripTallyWeb.TripsControllerTest do
  use TripTallyWeb.ConnCase, async: true

  @update_attrs %{
    "planned_cost" => %{
      "amount" => 350.00,
      "currency" => "EUR"
    }
  }
  @invalid_attrs %{
    "date_from" => ~D[2024-04-01],
    "date_to" => ~D[2024-04-10],
    "transport_type" => nil,
    "planned_cost" => nil,
    "location" => %{
      "country_code" => "PL",
      "city_name" => "Poznan"
    }
  }
  @invalid_attrs_no_country %{
    "transport_type" => nil,
    "planned_cost" => nil,
    "date_from" => ~D[2024-04-01],
    "date_to" => ~D[2024-04-10],
    "location" => %{
      "country_code" => nil,
      "city_name" => nil
    }
  }

  setup :register_and_log_in_user

  setup do
    category = insert(:category)

    {:ok, category: category}
  end

  describe "index" do
    test "lists all trips", %{conn: conn} do
      conn = get(conn, "/api/trips")
      assert %{"trips" => []} = json_response(conn, 200)
    end

    test "fetch correct trip when data is valid", %{conn: conn, user: %{id: user_id}} do
      %{transport_type: transport_type, id: trip_id} =
        new_trip = insert(:trip, %{user_id: user_id})

      conn = get(conn, "/api/trips/#{new_trip.id}")

      %{
        "transport_type" => ^transport_type,
        "date_from" => "2024-01-01",
        "date_to" => "2024-01-05",
        "id" => ^trip_id,
        "location" => %{
          "city_name" => "New York",
          "country_code" => "US"
        },
        "planned_cost" => %{"amount" => "1000", "currency" => "USD"},
        "expenses" => [],
        "total_expenses" => "0.0",
        "status" => "planned"
      } = json_response(conn, 200)
    end
  end

  describe "create" do
    test "creates trip with expenses", %{
      conn: conn,
      user: %{id: user_id},
      category: %{id: category_id}
    } do
      trip_attrs = %{
        "transport_type" => "Bus",
        "planned_cost" => %{"currency" => "EUR", "amount" => 1000.0},
        "date_from" => ~D[2024-04-01],
        "date_to" => ~D[2024-04-10],
        "location" => %{
          "country_code" => "PL",
          "city_name" => "Poznan"
        },
        "expenses" => [
          %{
            "name" => "Hotel",
            "price" => %{"currency" => "USD", "amount" => 1000.0},
            "date" => ~D[2024-04-02],
            "category_id" => category_id
          },
          %{
            "name" => "Flight",
            "price" => %{"currency" => "USD", "amount" => 1000.0},
            "date" => ~D[2024-04-01],
            "category_id" => category_id
          }
        ]
      }

      conn = post(conn, "/api/trips", trip_attrs)

      assert %{
               "user_id" => ^user_id,
               "planned_cost" => %{
                 "amount" => "1000",
                 "currency" => "EUR"
               },
               "transport_type" => "Bus",
               "location" => %{
                 "city_name" => "Poznan",
                 "country_code" => "PL"
               },
               "date_from" => "2024-04-01",
               "date_to" => "2024-04-10",
               "total_expenses" => "2000.00",
               "expenses" => [
                 %{
                   "name" => "Hotel",
                   "price" => %{"amount" => "1000", "currency" => "USD"},
                   "date" => "2024-04-02",
                   "category" => %{
                     "name" => "Test Category",
                     "translation_key" => "expense_category.test"
                   }
                 },
                 %{
                   "name" => "Flight",
                   "price" => %{"amount" => "1000", "currency" => "USD"},
                   "date" => "2024-04-01",
                   "category" => %{
                     "name" => "Test Category",
                     "translation_key" => "expense_category.test"
                   }
                 }
               ]
             } = json_response(conn, 201)
    end

    test "fails to create trip with invalid price of expenses", %{
      conn: conn,
      category: %{id: category_id}
    } do
      trip_attrs = %{
        "planned_cost" => %{"currency" => "EUR", "amount" => 3500.0},
        "transport_type" => "Bus",
        "date_from" => ~D[2024-04-01],
        "date_to" => ~D[2024-04-10],
        "location" => %{
          "country_code" => "PL",
          "city_name" => "Poznan"
        },
        "expenses" => [
          %{
            "name" => "",
            "price" => %{"currency" => "EUR", "amount" => nil},
            "date" => ~D[2024-04-02],
            "category_id" => category_id
          },
          %{
            "name" => "Flight",
            "planned_cost" => %{"currency" => "EUR", "amount" => 2000.0},
            "date" => ~D[2024-04-01],
            "category_id" => category_id
          }
        ]
      }

      conn = post(conn, "/api/trips", trip_attrs)

      response = json_response(conn, 422)

      assert %{
               "errors" => [
                 %{"field" => "price", "message" => "The Price cannot be blank."}
               ]
             } == response
    end

    test "fails to create trip with invalid category of expenses", %{conn: conn} do
      trip_attrs = %{
        "planned_cost" => %{"currency" => "EUR", "amount" => 3500.0},
        "transport_type" => "Bus",
        "date_from" => ~D[2024-04-01],
        "date_to" => ~D[2024-04-10],
        "location" => %{
          "country_code" => "PL",
          "city_name" => "Poznan"
        },
        "expenses" => [
          %{
            "name" => "",
            "price" => %{"currency" => "EUR", "amount" => 2000.0},
            "date" => ~D[2024-04-02],
            "category_id" => UUID.uuid1()
          },
          %{
            "name" => "Flight",
            "price" => %{"currency" => "EUR", "amount" => 2000.0},
            "date" => ~D[2024-04-01],
            "category_id" => UUID.uuid1()
          }
        ]
      }

      conn = post(conn, "/api/trips", trip_attrs)

      response = json_response(conn, 422)

      assert %{
               "errors" => [
                 %{"field" => "category_id", "message" => "does not exist"}
               ]
             } == response
    end

    test "renders created trip when city name has Greek char", %{conn: conn, user: %{id: user_id}} do
      conn =
        post(conn, "/api/trips", %{
          "transport_type" => "Bus",
          "planned_cost" => %{"currency" => "EUR", "amount" => 3500.0},
          "date_from" => ~D[2024-04-01],
          "date_to" => ~D[2024-04-10],
          "location" => %{"country_code" => "GR", "city_name" => "Αθήνα"}
        })

      assert %{
               "user_id" => ^user_id,
               "planned_cost" => %{
                 "amount" => "3500",
                 "currency" => "EUR"
               },
               "transport_type" => "Bus",
               "location" => %{
                 "city_name" => "Αθήνα",
                 "country_code" => "GR"
               },
               "total_expenses" => "0.0",
               "date_from" => "2024-04-01",
               "date_to" => "2024-04-10"
             } = json_response(conn, 201)
    end

    test "renders errors when planned_cost and transport_type is invalid", %{conn: conn} do
      conn = post(conn, "/api/trips", @invalid_attrs)

      expected_errors = [
        %{"field" => "planned_cost", "message" => "The Planned cost cannot be blank."},
        %{
          "field" => "transport_type",
          "message" => "The Transport type cannot be blank."
        }
      ]

      assert Enum.sort(json_response(conn, 422)["errors"]) ==
               Enum.sort(expected_errors)
    end

    test "renders errors when country_code and city_name is invalid", %{conn: conn} do
      conn = post(conn, "/api/trips", @invalid_attrs_no_country)
      response = json_response(conn, 422)

      expected_errors = [
        %{"field" => "city_name", "message" => "The City name cannot be blank."},
        %{"field" => "country_code", "message" => "The Country code cannot be blank."}
      ]

      assert Enum.sort(response["errors"]) == Enum.sort(expected_errors)
    end
  end

  describe "update" do
    test "renders updated trip when data is valid", %{conn: conn, user: %{id: user_id}} do
      %{id: trip_id} = insert(:trip, %{user_id: user_id})

      conn = put(conn, "/api/trips/#{trip_id}", @update_attrs)

      assert %{
               "id" => ^trip_id,
               "user_id" => ^user_id,
               "planned_cost" => %{
                 "amount" => "350",
                 "currency" => "EUR"
               },
               "transport_type" => "Bus",
               "location" => %{
                 "city_name" => "New York",
                 "country_code" => "US"
               },
               "total_expenses" => "0.0",
               "date_from" => "2024-01-01",
               "date_to" => "2024-01-05"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: %{id: user_id}} do
      %{id: trip_id} = insert(:trip, %{user_id: user_id})

      conn = put(conn, "/api/trips/#{trip_id}", @invalid_attrs)
      response = json_response(conn, 422)

      expected_errors = [
        %{"field" => "planned_cost", "message" => "The Planned cost cannot be blank."},
        %{
          "field" => "transport_type",
          "message" => "The Transport type cannot be blank."
        }
      ]

      assert Enum.sort(response["errors"]) == Enum.sort(expected_errors)
    end
  end

  describe "delete" do
    test "deletes chosen trip", %{conn: conn, user: %{id: user_id}} do
      %{id: trip_id} = insert(:trip, %{user_id: user_id})
      conn = delete(conn, "/api/trips/#{trip_id}")
      assert response(conn, 204)

      conn = get(conn, "/api/trips/#{trip_id}")
      assert response(conn, 404)
    end
  end
end
