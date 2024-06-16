defmodule TripTallyWeb.TripsControllerTest do
  use TripTallyWeb.ConnCase, async: true

  @create_attrs %{
    "transport_type" => "Bus",
    "planned_cost" => 300,
    "date_from" => ~D[2024-04-01],
    "date_to" => ~D[2024-04-10],
    "country_code" => "PL",
    "city_name" => "Poznań"
  }
  @update_attrs %{
    "planned_cost" => 350
  }
  @invalid_attrs %{
    "transport_type" => nil,
    "planned_cost" => nil,
    "date_from" => ~D[2024-04-01],
    "date_to" => ~D[2024-04-10],
    "country_code" => "PL",
    "city_name" => "Poznan"
  }
  @invalid_attrs_no_country %{
    "transport_type" => nil,
    "planned_cost" => nil,
    "date_from" => ~D[2024-04-01],
    "date_to" => ~D[2024-04-10],
    "country_code" => nil,
    "city_name" => nil
  }

  setup :register_and_log_in_user

  describe "index" do
    test "lists all trips", %{conn: conn} do
      conn = get(conn, "/api/trips")
      assert %{"trips" => []} = json_response(conn, 200)
    end
  end

  describe "create" do
    test "renders created trip when data is valid", %{conn: conn, user: %{id: user_id}} do
      {:ok, trip_id} = create_trip(conn)

      conn = get(conn, "/api/trips/#{trip_id}")

      assert %{
               "trip" => %{
                 "trip_id" => ^trip_id,
                 "user_id" => ^user_id,
                 "planned_cost" => 300,
                 "transport_type" => "Bus",
                 "city_name" => "Poznań",
                 "country_code" => "PL",
                 "date_from" => "2024-04-01",
                 "date_to" => "2024-04-10"
               }
             } = json_response(conn, 200)
    end

    test "renders created trip when city name has Greek char", %{conn: conn, user: %{id: user_id}} do
      conn =
        post(conn, "/api/trips", %{
          "transport_type" => "Bus",
          "planned_cost" => 300,
          "date_from" => ~D[2024-04-01],
          "date_to" => ~D[2024-04-10],
          "country_code" => "GR",
          "city_name" => "Αθήνα"
        })

      assert %{"trip" => %{"trip_id" => trip_id}} = json_response(conn, 201)

      conn = get(conn, "/api/trips/#{trip_id}")

      assert %{
               "trip" => %{
                 "trip_id" => ^trip_id,
                 "user_id" => ^user_id,
                 "planned_cost" => 300,
                 "transport_type" => "Bus",
                 "city_name" => "Αθήνα",
                 "country_code" => "GR",
                 "date_from" => "2024-04-01",
                 "date_to" => "2024-04-10"
               }
             } = json_response(conn, 200)
    end

    test "renders errors when planned_cost and transport_type is invalid", %{conn: conn} do
      conn = post(conn, "/api/trips", @invalid_attrs)

      assert %{
               "errors" => %{
                 "transport_type" => ["can't be blank"],
                 "planned_cost" => ["can't be blank"]
               }
             } = json_response(conn, 422)
    end

    test "renders errors when country_code and city_name is invalid", %{conn: conn} do
      conn = post(conn, "/api/trips", @invalid_attrs_no_country)

      assert %{
               "errors" => %{
                 "country_code" => ["can't be blank"],
                 "city_name" => ["can't be blank"]
               }
             } = json_response(conn, 422)
    end
  end

  describe "update" do
    test "renders updated trip when data is valid", %{conn: conn, user: %{id: user_id}} do
      {:ok, trip_id} = create_trip(conn)

      conn = put(conn, "/api/trips/#{trip_id}", %{"trip_params" => @update_attrs})

      assert %{
               "trip" => %{
                 "trip_id" => ^trip_id,
                 "user_id" => ^user_id,
                 "planned_cost" => 350,
                 "transport_type" => "Bus",
                 "city_name" => "Poznań",
                 "country_code" => "PL",
                 "date_from" => "2024-04-01",
                 "date_to" => "2024-04-10"
               }
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, trip_id} = create_trip(conn)

      conn = put(conn, "/api/trips/#{trip_id}", %{"trip_params" => @invalid_attrs})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "transport_type" => ["can't be blank"],
                 "planned_cost" => ["can't be blank"]
               }
             }
    end
  end

  describe "delete" do
    test "deletes chosen trip", %{conn: conn} do
      {:ok, trip_id} = create_trip(conn)
      conn = delete(conn, "/api/trips/#{trip_id}")
      assert response(conn, 204)

      conn = get(conn, "/api/trips/#{trip_id}")
      assert response(conn, 404)
    end
  end

  defp create_trip(conn) do
    conn = post(conn, "/api/trips", @create_attrs)
    assert %{"trip" => %{"trip_id" => id}} = json_response(conn, 201)
    {:ok, id}
  end
end
