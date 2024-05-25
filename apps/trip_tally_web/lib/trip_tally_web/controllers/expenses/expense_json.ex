defmodule TripTallyWeb.Expenses.ExpenseJSON do
  alias TripTally.Expenses.Expense

  @doc """
  Renders a list of expenses.
  """
  def index(%{expenses: expenses}) do
    %{expenses: Enum.map(expenses, &data/1)}
  end

  @doc """
  Renders a single expense.
  """
  def show(%{expense: expense}) do
    data(expense)
  end

  defp data(%Expense{} = expense) do
    %{
      id: expense.id,
      name: expense.name,
      amount: expense.price.amount,
      currency: expense.price.currency,
      date: expense.date,
      trip_id: expense.trip_id,
      user_id: expense.user_id,
      created_at: expense.inserted_at,
      updated_at: expense.updated_at
    }
  end
end
