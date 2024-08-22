defmodule TripTally.Trips.Locations do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias TripTally.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, except: [:__meta__, :users]}
  schema "locations" do
    field :country_code, :string
    field :city_name, :string

    belongs_to :users, User, type: :binary_id, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:country_code, :city_name])
    |> validate_required([:country_code, :city_name])
    |> validate_city_name_syntax()
    |> unique_constraint(:city_name_country, name: :city_country_index)
  end

  # Provides a way to validate that a city name contains only letters and spaces, accommodating a wide range of
  # international characters.
  defp validate_city_name_syntax(changeset) do
    city_name = get_field(changeset, :city_name) || ""

    if String.replace(city_name, ~r/[^\p{L}\s]/u, "") === city_name do
      changeset
    else
      add_error(changeset, :city_name, "City name can only contain letters and spaces.",
        validation: :format
      )
    end
  end
end
