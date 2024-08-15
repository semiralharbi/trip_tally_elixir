defmodule TripTally.Expenses.Expense do
  @moduledoc """
  This module holds Expenses schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "expenses" do
    field :name, :string
    field :date, :date
    field :price, Money.Ecto.Composite.Type
    ## TODO: Add expense_category

    belongs_to :trips, TripTally.Trips.Trips,
      type: :binary_id,
      foreign_key: :trip_id

    belongs_to :users, TripTally.Accounts.User, type: :binary_id, foreign_key: :user_id

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
  end

  def changeset_update(expense, attrs) do
    expense
    |> cast(attrs, @update_cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:trip_id)
  end
end
