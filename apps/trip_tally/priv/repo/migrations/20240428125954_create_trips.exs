defmodule TripTally.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :transport_type, :string
      add :planned_cost, :float
      add :date_from, :date
      add :date_to, :date
      add :location_id, references(:locations, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:trips, [:location_id])
    create index(:trips, [:transport_type])
    create index(:trips, [:user_id])
  end
end
