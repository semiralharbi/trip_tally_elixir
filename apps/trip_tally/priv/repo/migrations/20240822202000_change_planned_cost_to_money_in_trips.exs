defmodule TripTally.Repo.Migrations.ChangePlannedCostToMoneyInTrips do
  use Ecto.Migration

  def change do
    alter table(:trips) do
      remove :planned_cost
      add :planned_cost, :money_with_currency
    end
  end
end
