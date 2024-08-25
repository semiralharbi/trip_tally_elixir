defmodule TripTally.Expenses.Expense do
  @moduledoc """
  This module holds Expenses schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, except: [:__meta__, :user, :trip]}
  schema "expenses" do
    field :name, :string
    field :date, :date
    field :price, Money.Ecto.Composite.Type

    belongs_to :trip, TripTally.Trips.Trip, type: :binary_id, foreign_key: :trip_id
    belongs_to :user, TripTally.Accounts.User, type: :binary_id, foreign_key: :user_id

    timestamps()
  end

  @cast_fields [:name, :price, :date, :trip_id, :user_id]
  @required_fields [:price, :date, :trip_id, :user_id]
  @update_cast_fields [:name, :price, :date]
  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(expense, attrs) do
    expense
    |> cast(attrs, @update_cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:user_id)
  end
end
