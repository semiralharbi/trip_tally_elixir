defmodule TripTally.Locations do
  @moduledoc false

  import Ecto.Query, warn: false

  alias TripTally.Repo
  alias TripTally.Trips.Locations

  @doc """
  Creates a location or fetches an existing one based on the given attributes.
  """
  def create_or_fetch_location(
        %{"country_code" => country_code, "city_name" => city_name} = attrs
      ) do
    case get_location_by_country_and_city(country_code, city_name) do
      nil ->
        create_location(attrs)

      location ->
        {:ok, location}
    end
  end

  defp create_location(attrs) do
    %Locations{}
    |> Locations.changeset(attrs)
    |> Repo.insert()
  end

  def get_location_by_country_and_city(country_code, city_name) do
    Locations
    |> where([l], l.country_code == ^country_code and l.city_name == ^city_name)
    |> Repo.one()
  end
end
