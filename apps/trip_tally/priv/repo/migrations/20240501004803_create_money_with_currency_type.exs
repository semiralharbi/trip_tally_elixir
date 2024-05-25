defmodule TripTally.Repo.Migrations.CreateMoneyWithCurrencyType do
  use Ecto.Migration

  def up do
    execute """
    CREATE TYPE money_with_currency AS (
      amount INTEGER,
      currency VARCHAR(3)
    );
    """
  end

  def down do
    execute """
    DROP TYPE money_with_currency;
    """
  end
end
