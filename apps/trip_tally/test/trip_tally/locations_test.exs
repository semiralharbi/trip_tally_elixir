defmodule TripTally.LocationsTest do
  alias TripTally.Trips.Locations
  use TripTally.DataCase

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  describe "create_or_fetch_location/1" do
    test "create_or_fetch_location succesfully", %{user: %{id: user_id}} do
      assert {:ok, %Locations{city_name: "New York", country_code: "US"}} =
               TripTally.Locations.create_or_fetch_location(%{
                 "location" => %{"city_name" => "New York", "country_code" => "US"},
                 "user_id" => user_id
               })
    end

    test "create_or_fetch_location fails when city_name contains special char" do
      {:error, changeset} =
        TripTally.Locations.create_or_fetch_location(%{
          "city_name" => "N@w York",
          "country_code" => "US"
        })

      assert {"City name can only contain letters and spaces.", [validation: :format]} =
               changeset.errors[:city_name]
    end

    test "create_or_fetch_location fails when city_name contains numbers" do
      {:error, changeset} =
        TripTally.Locations.create_or_fetch_location(%{
          "city_name" => "New Y0rk",
          "country_code" => "US"
        })

      assert {"City name can only contain letters and spaces.", [validation: :format]} =
               changeset.errors[:city_name]
    end
  end
end
