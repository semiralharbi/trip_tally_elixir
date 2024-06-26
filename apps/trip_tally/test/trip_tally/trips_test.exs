defmodule TripTally.TripsTest do
  use TripTally.DataCase
  alias TripTally.TripsFixtures
  alias TripTally.Trips

  @invalid_user "123e4567-e89b-12d3-a456-426614174000"
  @invalid_trip_id "123e4567-e89b-12d3-a456-426614178000"

  describe "trips" do
    test "creates trip with location successfully" do
      attrs = %{"country_code" => "PL", "city_name" => "Bydgoszcz"}
      assert {:ok, trip} = TripsFixtures.trips_fixture(attrs)
      assert trip.location_id
    end

    test "fail to creates trip with invalid location data" do
      attrs = %{"country_code" => nil, "city_name" => nil}
      {:error, changeset} = Trips.create_trip_with_location(attrs)

      assert {"can't be blank", [validation: :required]} =
               changeset.errors[:country_code]

      assert {"can't be blank", [validation: :required]} =
               changeset.errors[:city_name]
    end

    test "fetches trip by existing id" do
      {:ok, trip} = TripsFixtures.trips_fixture()
      assert {:ok, fetched_trip} = Trips.fetch_trip_by_id(trip.id)
      assert fetched_trip.id == trip.id
    end

    test "attempts to fetch trip by non-existing id returns nil" do
      assert {:error, :not_found} == Trips.fetch_trip_by_id(@invalid_trip_id)
    end

    test "fetches all trips by user" do
      {:ok, trip} = TripsFixtures.trips_fixture()
      assert Trips.get_trips_by_user(trip.user_id) != []
    end

    test "fetches trips by user with no trips returns empty list" do
      assert [] == Trips.get_trips_by_user(@invalid_user)
    end

    test "updates trip successfully" do
      {:ok, trip} = TripsFixtures.trips_fixture()
      new_attrs = %{"planned_cost" => 200}
      assert {:ok, updated_trip} = Trips.update(trip.id, new_attrs)
      assert updated_trip.planned_cost == 200
      assert trip.planned_cost != updated_trip.planned_cost
    end

    test "updates non-existent trip" do
      assert_raise Ecto.NoResultsError, fn ->
        Trips.update(@invalid_trip_id, %{"planned_cost" => 200})
      end
    end

    test "deletes trip successfully" do
      {:ok, trip} = TripsFixtures.trips_fixture()
      assert {:ok, _} = Trips.delete(trip.id)
      assert {:error, :not_found} == Trips.fetch_trip_by_id(trip.id)
    end

    test "deletes non-existent trip raises error" do
      assert {:error, :not_found} = Trips.delete(@invalid_trip_id)
    end

    # New tests for different formats

    test "handles date formats correctly" do
      {:ok, trip} = TripsFixtures.trips_fixture()

      new_attrs1 = %{"date_from" => "2023-06-25", "date_to" => "2023-07-25"}
      assert {:ok, updated_trip1} = Trips.update(trip.id, new_attrs1)
      assert updated_trip1.date_from == ~D[2023-06-25]
      assert updated_trip1.date_to == ~D[2023-07-25]

      new_attrs2 = %{"date_from" => "25-06-2023", "date_to" => "25-07-2023"}
      assert {:ok, updated_trip2} = Trips.update(trip.id, new_attrs2)
      assert updated_trip2.date_from == ~D[2023-06-25]
      assert updated_trip2.date_to == ~D[2023-07-25]

      new_attrs3 = %{"date_from" => "25.06.2023", "date_to" => "25.07.2023"}
      assert {:ok, updated_trip3} = Trips.update(trip.id, new_attrs3)
      assert updated_trip3.date_from == ~D[2023-06-25]
      assert updated_trip3.date_to == ~D[2023-07-25]
    end

    test "handles planned cost formats correctly" do
      {:ok, trip} = TripsFixtures.trips_fixture()

      new_attrs1 = %{"planned_cost" => "300"}
      assert {:ok, updated_trip1} = Trips.update(trip.id, new_attrs1)
      assert updated_trip1.planned_cost == 300.0

      new_attrs2 = %{"planned_cost" => 400}
      assert {:ok, updated_trip2} = Trips.update(trip.id, new_attrs2)
      assert updated_trip2.planned_cost == 400.0

      new_attrs3 = %{"planned_cost" => 400.0}
      assert {:ok, updated_trip3} = Trips.update(trip.id, new_attrs3)
      assert updated_trip3.planned_cost == 400.0

      new_attrs4 = %{"planned_cost" => "invalid_cost"}
      assert {:error, changeset} = Trips.update(trip.id, new_attrs4)

      assert changeset.errors ==
               [planned_cost: {"is invalid", [type: :float, validation: :cast]}]
    end
  end
end
