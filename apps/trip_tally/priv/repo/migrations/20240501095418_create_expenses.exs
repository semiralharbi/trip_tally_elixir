defmodule TripTally.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :price, :money_with_currency
      add :date, :date
      add :trip_id, references(:trips, on_delete: :delete, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete, type: :binary_id)

      timestamps()
    end

    create index(:expenses, [:trip_id])
    create index(:expenses, [:name])
    create index(:expenses, [:user_id])
    create index(:expenses, [:date])
  end
end
