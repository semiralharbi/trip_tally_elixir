defmodule TripTally.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :translation_key, :string, null: false

      timestamps()
    end

    alter table(:expenses) do
      add :category_id, references(:categories, type: :binary_id, on_delete: :restrict),
        null: false
    end

    create index(:expenses, [:category_id])
  end
end
