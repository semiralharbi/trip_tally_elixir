defmodule TripTally.Repo.Migrations.AddIsActiveToTrip do
  use Ecto.Migration

  def change do
    alter table(:trips) do
      add :status, :string, default: "planned"
    end
  end
end
