defmodule TripTally.Trips.Trip do
  @moduledoc """
  Trip schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Money.Ecto.Composite.Type, as: MoneyType
  alias TripTally.Expenses.Expense
  alias TripTally.Repo
  alias TripTally.Utils.DateParser

  @trip_statuses [:planned, :in_progress, :completed]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, except: [:__meta__, :location_id, :user]}

  schema "trips" do
    field :transport_type, :string
    field :planned_cost, MoneyType
    field :date_from, :date
    field :date_to, :date
    field :status, Ecto.Enum, values: @trip_statuses, default: :planned
    field :total_expenses, :float, virtual: true

    belongs_to :location, TripTally.Trips.Locations, type: :binary_id, foreign_key: :location_id
    belongs_to :user, TripTally.Accounts.User, type: :binary_id, foreign_key: :user_id

    has_many :expenses, Expense, foreign_key: :trip_id

    timestamps()
  end

  @required_params ~w(transport_type date_from date_to planned_cost location_id user_id status)a
  @update_params ~w(transport_type planned_cost date_from date_to status location_id)a

  def changeset(trip, attrs) do
    attrs = attrs |> normalize_dates()

    trip
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> validate_date_order()
    |> validate_dates_overlap()
  end

  def changeset_update(trip, attrs) do
    attrs = attrs |> normalize_dates()

    trip
    |> cast(attrs, @update_params)
    |> validate_required(@update_params)
    |> validate_date_order()
    |> validate_dates_overlap()
  end

  defp validate_dates_overlap(changeset) do
    user_id = get_field(changeset, :user_id)
    date_from = get_field(changeset, :date_from)
    date_to = get_field(changeset, :date_to)
    trip_id = get_field(changeset, :id)

    overlapping_trips_query =
      __MODULE__
      |> where([t], t.user_id == ^user_id)
      |> where([t], t.date_from < ^date_to and t.date_to > ^date_from)
      |> exclude_current_trip(trip_id)

    case Repo.exists?(overlapping_trips_query) do
      true -> add_error(changeset, :date_from, "This trip overlaps with an existing trip.")
      false -> changeset
    end
  end

  defp exclude_current_trip(query, nil), do: query

  defp exclude_current_trip(query, trip_id) do
    where(query, [t], t.id != ^trip_id)
  end

  defp validate_date_order(changeset) do
    date_from = get_field(changeset, :date_from)
    date_to = get_field(changeset, :date_to)

    if Date.compare(date_from, date_to) != :lt do
      add_error(changeset, :date_to, "The end date must be after the start date.")
    else
      changeset
    end
  end

  defp normalize_dates(attrs) do
    attrs
    |> DateParser.normalize_date("date_from")
    |> DateParser.normalize_date("date_to")
  end
end
