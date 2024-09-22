defmodule TripTallyWeb.Expenses.ExpenseJSON do
  alias TripTally.Money

  @doc """
  Renders a list of expenses.
  """
  def index(%{expenses: expenses}) do
    expenses = Money.convert_to_decimal_amount(expenses)
    %{expenses: expenses}
  end

  @doc """
  Renders a single expense.
  """
  def show(%{expense: expense}) do
    expense = Money.convert_to_decimal_amount(expense)
    %{expense: expense}
  end

  @doc """
  Renders expense categories.
  """
  def categories(%{categories: categories}) do
    %{categories: categories}
  end
end
