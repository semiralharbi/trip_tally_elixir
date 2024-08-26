defmodule TripTally.Repo.Migrations.AddExpenseCategories do
  use Ecto.Migration

  def change do
    alter table(:expenses) do
      add :category, :string
    end
  end
end
