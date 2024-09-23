defmodule TripTally.Expenses do
  @moduledoc """
  This module holds Expenses schema
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias TripTally.Expenses.Category
  alias TripTally.Expenses.Expense
  alias TripTally.Money

  alias TripTally.Repo

  @doc """
  Returns the list of all user expenses.
  """
  def get_all_user_expenses(user_id) do
    Expense
    |> where([e], e.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Gets all trip expenses.
  """
  def get_all_trip_expenses(user_id, trip_id) do
    Expense
    |> where([e], e.user_id == ^user_id)
    |> where([e], e.trip_id == ^trip_id)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Gets all expense categories.
  """
  def get_all_expense_categories do
    Repo.all(Category)
  end

  @doc """
  Gets single expense by id.
  """
  def get_expense(id, user_id) do
    case Repo.get_by(Expense, id: id, user_id: user_id) do
      nil -> {:error, :not_found}
      expense -> {:ok, expense |> Repo.preload(:category)}
    end
  end

  @doc """
  Creates an expense.

  example_attrs = %{
      name: "some name",
      date: ~D[2024-04-30],
      price: Money.new(12_050, :USD),
      trip_id: binary_id,
      user_id: binary_id
    }
  """
  def create(attrs \\ %{}) do
    params = Money.create_price(attrs, "price")

    %Expense{}
    |> Expense.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, expense} ->
        {:ok, Repo.preload(expense, :category)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Creates multiple expenses.

  example_attrs = [
    %{
        name: "some name",
        date: ~D[2024-04-30],
        price: Money.new(12_050, :USD),
        trip_id: binary_id,
        user_id: binary_id
      }
  ]

  """
  def create_multiple(expenses) do
    multi =
      Enum.with_index(expenses)
      |> Enum.reduce(Multi.new(), fn {expense_attrs, index}, multi ->
        Multi.run(multi, :"insert_#{index}", fn _repo, _changes ->
          create(expense_attrs)
        end)
      end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok, result |> Map.values()}

      {:error, _failed_operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an expense by id.

   example_attrs = %{
      id: binary_id,
      price: Money.new(12_050, :USD),
      user_id: binary_id
    }
  """
  def update(id, user_id, attrs) do
    with {:ok, expense} <- get_expense(id, user_id),
         updated_attrs <- Money.maybe_update_price(expense, attrs) do
      Expense.changeset_update(expense, updated_attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a expense by id.
  """
  def delete(id, user_id) do
    case Repo.get_by(Expense, id: id, user_id: user_id) do
      nil -> {:error, :not_found}
      expense -> Repo.delete(expense)
    end
  end
end
