defmodule TripTallyWeb.Expenses.ExpenseController do
  use TripTallyWeb.AuthController

  alias TripTally.Expenses

  @doc """
  Purpose: Fetches all expenses for the currently logged-in user, or expenses for a specific trip if 'trip_id' is provided.

  1. Endpoint: GET /api/expenses
  2. Endpoint: GET /api/expenses/:trip_id

  Parameters:
    trip_id (Optional, Binary ID): ID of the trip for which expenses are to be fetched. If not provided, all expenses for the user are fetched.

  Returns: JSON array of expenses, either for a specific trip or all expenses associated with the user.
  """
  def index(conn, %{"trip_id" => trip_id}, user_id) do
    expenses = Expenses.get_all_trip_expenses(user_id, trip_id)
    render(conn, "index.json", expenses: expenses)
  end

  def index(conn, _params, user_id) do
    expenses = Expenses.get_all_user_expenses(user_id)
    render(conn, "index.json", expenses: expenses)
  end

  @doc """
  Purpose: Creates a new expense and associates it with the logged-in user.

  Endpoint: POST /api/expenses

  Parameters:
    - name (String): Name of the expense.
    - date (Date): Date of the expense.
    - amount (Integer): Amount of expense
    - currency (String): Currency
    - trip_id (Binary ID): ID of the trip associated with this expense.
    - user_id (Automatically set from session): ID of the logged-in user.

  Returns: JSON representation of the newly created expense with its unique identifier, or an error message if the creation fails.
  """

  def create(conn, params, user_id) do
    params =
      params
      |> Map.put("user_id", user_id)

    case Expenses.create(params) do
      {:ok, expense} ->
        conn
        |> put_status(:created)
        |> render("show.json", expense: expense)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Purpose: Retrieves a specific expense by its ID, ensuring it belongs to the logged-in user.

  Endpoint: GET /api/expenses/:id

  Parameters:
    id (Binary ID): ID of the expense to fetch.

  Returns: JSON representation of the specific expense if found and belongs to the user; otherwise, a not-found or forbidden status.
  """
  def show(conn, %{"id" => id}, user_id) do
    case Expenses.get_expense(id, user_id) do
      {:error, _reason} ->
        {:error, :not_found}

      {:ok, expense} ->
        render(conn, "show.json", expense: expense)
    end
  end

  @doc """
  Purpose: Updates an existing expense's details, validating that the expense belongs to the logged-in user.

  Endpoint: PUT /api/expenses/:id

  Parameters:
    id (Binary ID): ID of the expense to update.
    expense (Map): Contains fields of the expense that may be updated.

  Returns: JSON representation of the updated expense if successful; otherwise, an error message.
  """

  def update(conn, %{"id" => id, "expense" => params}, user_id) do
    case Expenses.update(id, user_id, params) do
      {:ok, updated_expense} ->
        render(conn, "show.json", expense: updated_expense)

      error ->
        error
    end
  end

  @doc """
  Purpose: Deletes a specific expense, ensuring that the expense belongs to the logged-in user.

  Endpoint: DELETE /api/expenses/:id

  Parameters:
    id (Binary ID): ID of the expense to delete.

  Returns: No content on successful deletion; otherwise, an error message.
  """
  def delete(conn, %{"id" => id}, user_id) do
    case Expenses.delete(id, user_id) do
      {:ok, _} ->
        send_resp(conn, 204, "")

      error ->
        error
    end
  end
end
