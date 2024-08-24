defmodule TripTally.TripsTest do
  use TripTally.DataCase

  alias TripTally.Trips

  @invalid_user "123e4567-e89b-12d3-a456-426614174000"
  @invalid_trip_id "123e4567-e89b-12d3-a456-426614178000"

  describe "trips" do
    test "checks if there is a trip for today" do
      trip = insert(:trip, %{date_from: Timex.now()})
      insert_list(4, :expense, %{user_id: trip.user_id, trip_id: trip.id})

      assert {:ok,
              %TripTally.Trips.Trip{
                date_to: ~D[2024-01-05],
                location: %TripTally.Trips.Locations{
                  city_name: "New York",
                  country_code: "US"
                },
                planned_cost: %Money{amount: 100_000, currency: :USD},
                transport_type: "Bus",
                expenses: expenses
              }} = Trips.fetch_trip_starting_today(trip.user_id)

      assert length(expenses) == 4
    end

    test "creates trip with location successfully" do
      additional_attrs = %{
        "country_code" => "PL",
        "city_name" => "Bydgoszcz",
        "amount" => 350.00,
        "currency" => "EUR"
      }

      attrs =
        string_params_for(:trip, additional_attrs)
        |> Map.delete("planned_cost")

      {:ok, trip} = Trips.create_trip_with_location(attrs)
      assert trip.location.country_code == "PL"
      assert trip.location.city_name == "Bydgoszcz"

      additional_attrs = %{
        "country_code" => "PL",
        "city_name" => "Bydgoszcz",
        "amount" => 350.68,
        "currency" => "EUR"
      }

      attrs =
        string_params_for(:trip, additional_attrs)
        |> Map.delete("planned_cost")

      string_params_for(:trip, additional_attrs)
      |> Map.delete("planned_cost")

      {:ok, trip} = Trips.create_trip_with_location(attrs)
      assert trip.location.country_code == "PL"
      assert trip.location.city_name == "Bydgoszcz"
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
      trip = insert(:trip)
      assert {:ok, fetched_trip} = Trips.fetch_trip_by_id(trip.id)
      assert fetched_trip.id == trip.id
    end

    test "attempts to fetch trip by non-existing id returns nil" do
      assert {:error, :not_found} == Trips.fetch_trip_by_id(@invalid_trip_id)
    end

    test "fetches all trips by user" do
      trip = insert(:trip)
      assert Trips.get_trips_by_user(trip.user_id) != []
    end

    test "fetches trips by user with no trips returns empty list" do
      assert [] == Trips.get_trips_by_user(@invalid_user)
    end

    test "updates trip successfully" do
      trip = insert(:trip)
      new_attrs = %{"amount" => 35_000, "currency" => "EUR"}
      assert {:ok, updated_trip} = Trips.update(trip.id, new_attrs)
      assert updated_trip.planned_cost == %Money{amount: 35_000, currency: :EUR}
      assert trip.planned_cost != updated_trip.planned_cost
    end

    test "updates non-existent trip" do
      assert {:error, :not_found} =
               Trips.update(@invalid_trip_id, %{"amount" => 35_000, "currency" => "EUR"})
    end

    test "deletes trip successfully" do
      trip = insert(:trip)
      assert {:ok, _} = Trips.delete(trip.id)
      assert {:error, :not_found} == Trips.fetch_trip_by_id(trip.id)
    end

    test "deletes non-existent trip raises error" do
      assert {:error, :not_found} = Trips.delete(@invalid_trip_id)
    end

    test "handles date formats correctly" do
      trip = insert(:trip)

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
      trip = insert(:trip)

      new_attrs1 = %{"amount" => "350", "currency" => "EUR"}
      new_attrs1 = %{"amount" => "350", "currency" => "EUR"}
      assert {:ok, updated_trip1} = Trips.update(trip.id, new_attrs1)
      assert updated_trip1.planned_cost.amount == 350
      assert updated_trip1.planned_cost.amount == 350

      new_attrs2 = %{"amount" => 35_000, "currency" => "EUR"}
      assert {:ok, updated_trip2} = Trips.update(trip.id, new_attrs2)
      assert updated_trip2.planned_cost.amount == 35_000

      new_attrs3 = %{"amount" => 350.0, "currency" => "EUR"}
      new_attrs3 = %{"amount" => 350.0, "currency" => "EUR"}
      assert {:ok, updated_trip3} = Trips.update(trip.id, new_attrs3)
      assert updated_trip3.planned_cost.amount == 35_000

      new_attrs4 = %{"amount" => nil, "currency" => "EUR"}
      new_attrs4 = %{"amount" => nil, "currency" => "EUR"}
      assert {:error, changeset} = Trips.update(trip.id, new_attrs4)

      assert changeset.errors ==
               [
                 planned_cost:
                   {"is invalid", [type: Money.Ecto.Composite.Type, validation: :cast]}
               ]

      [
        planned_cost: {"is invalid", [type: Money.Ecto.Composite.Type, validation: :cast]}
      ]
    end
  end
end
