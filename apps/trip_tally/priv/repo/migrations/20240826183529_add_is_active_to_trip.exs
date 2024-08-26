defmodule TripTally.Repo.Migrations.AddIsActiveToTrip do
  use Ecto.Migration

  def change do
    alter table(:trips) do
      add :is_active, :boolean, default: false
    end
  end
end
