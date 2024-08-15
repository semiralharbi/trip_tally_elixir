defmodule TripTally.Trips.Trips do
  @moduledoc """
  Trips schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Timex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "trips" do
    field :transport_type, :string
    field :planned_cost, :float
    field :date_from, :date
    field :date_to, :date

    belongs_to :location, TripTally.Trips.Locations, type: :binary_id, foreign_key: :location_id
    belongs_to :users, TripTally.Accounts.User, type: :binary_id, foreign_key: :user_id

    timestamps()
  end

  @required_params ~w(transport_type planned_cost date_from date_to location_id user_id)a
  @update_params ~w(transport_type planned_cost date_from date_to)a

  def changeset(trip, attrs) do
    attrs = attrs |> normalize_dates()

    trip
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end

  def changeset_update(trip, attrs) do
    attrs = attrs |> normalize_dates()

    trip
    |> cast(attrs, @update_params)
    |> validate_required(@update_params)
  end

  defp normalize_dates(attrs) do
    attrs
    |> normalize_date("date_from")
    |> normalize_date("date_to")
  end

  defp normalize_date(attrs, field) do
    case Map.get(attrs, field) do
      nil ->
        attrs

      date when is_binary(date) ->
        case parse_date(date) do
          {:ok, dt} -> Map.put(attrs, field, dt)
          {:error, _} -> attrs
        end

      date when is_integer(date) ->
        dt = DateTime.from_unix!(date, :second) |> DateTime.to_date()
        Map.put(attrs, field, dt)

      _ ->
        attrs
    end
  end

  defp parse_date(date_string) do
    formats = [
      "{0D}-{0M}-{YYYY}",
      "{YYYY}-{0M}-{0D}",
      "{0M}-{0D}-{YYYY}",
      "{0D}/{0M}/{YYYY}",
      "{YYYY}/{0M}/{0D}",
      "{0M}/{0D}/{YYYY}",
      "{0M}.{0D}.{YYYY}",
      "{0D}.{0M}.{YYYY}",
      "{YYYY}.{0M}.{0D}",
      "{YYYYMMDD}",
      "{0D} {Mfull} {YYYY}",
      "{Mfull} {0D}, {YYYY}",
      "{0D}-{Mshort}-{YYYY}",
      "{Mshort}-{0D}-{YYYY}",
      "{0D}/{Mshort}/{YYYY}"
    ]

    Enum.find_value(formats, fn format ->
      case Timex.parse(date_string, format) do
        {:ok, datetime} ->
          {:ok, Timex.to_date(datetime)}

        _ ->
          nil
      end
    end) || {:error, :invalid_format}
  end
end
