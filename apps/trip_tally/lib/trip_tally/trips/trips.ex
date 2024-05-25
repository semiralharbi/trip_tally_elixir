defmodule TripTally.Trips.Trips do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "trips" do
    field :transport_type, :string
    field :planned_cost, :integer
    field :date_from, :date
    field :date_to, :date

    belongs_to :location, TripTally.Trips.Locations, type: :binary_id, foreign_key: :location_id
    belongs_to :users, TripTally.Accounts.User, type: :binary_id, foreign_key: :user_id

    timestamps()
  end

  @required_params ~w(transport_type planned_cost date_from date_to location_id user_id)a
  @update_params ~w(transport_type planned_cost date_from date_to)a

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end

  @doc """
  Changeset used for updateding the record. Updating `user_id` and `location_id` should not be possible
  """
  def changeset_update(trip, attrs) do
    trip
    |> cast(attrs, @update_params)
    |> validate_required(@update_params)
  end
end
