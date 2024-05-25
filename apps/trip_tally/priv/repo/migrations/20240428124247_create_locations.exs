defmodule TripTally.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :country_code, :string
      add :city_name, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:locations, [:user_id])
    create index(:locations, [:country_code])
    create unique_index(:locations, [:city_name, :country_code], name: :city_country_index)
  end
end
