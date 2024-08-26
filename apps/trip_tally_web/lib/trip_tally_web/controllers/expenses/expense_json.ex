defmodule TripTallyWeb.Expenses.ExpenseJSON do
  @doc """
  Renders a list of expenses.
  """
  def index(%{expenses: expenses}) do
    expenses = Enum.map(expenses, &convert_planned_cost_amount/1)
    %{expenses: expenses}
  end

  @doc """
  Renders a single expense.
  """
  def show(%{expense: expense}) do
    expense = convert_planned_cost_amount(expense)
    %{expense: expense}
  end

  def categories(%{categories: categories}) do
    %{categories: categories}
  end

  defp convert_planned_cost_amount(expense) do
    Map.update(expense, :price, 0, fn price ->
      Map.update(price, :amount, 0, fn amount ->
        amount / 100.0
      end)
    end)
  end
end
