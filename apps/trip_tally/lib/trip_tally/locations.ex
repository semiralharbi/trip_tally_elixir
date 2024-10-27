defmodule TripTally.Locations do
  @moduledoc false

  import Ecto.Query, warn: false

  alias TripTally.Repo
  alias TripTally.Trips.Locations

  @doc """
  Creates a location or fetches an existing one based on the given attributes.
  """
  def create_or_fetch_location(%{
        "location" => %{"country_code" => country_code, "city_name" => city_name},
        "user_id" => user_id
      }) do
    case get_location_by_country_and_city(country_code, city_name) do
      nil ->
        create_location(%{
          "country_code" => country_code,
          "city_name" => city_name,
          "user_id" => user_id
        })

      location ->
        {:ok, location}
    end
  end

  def create_or_fetch_location(attrs), do: {:error, Locations.changeset(%Locations{}, attrs)}

  defp create_location(attrs) do
    %Locations{}
    |> Locations.changeset(attrs)
    |> Repo.insert()
  end

  def get_location_by_country_and_city(country_code, city_name)
      when not is_nil(country_code) and not is_nil(city_name) do
    Locations
    |> where([l], l.country_code == ^country_code and l.city_name == ^city_name)
    |> Repo.one()
  end

  def get_location_by_country_and_city(_, _), do: nil
end
