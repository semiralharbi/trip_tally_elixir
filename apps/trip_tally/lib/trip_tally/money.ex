defmodule TripTally.Money do
  @moduledoc """
  This module holds helpers for Money
  """

  alias TripTally.Expenses.Expense

  def create_price(attrs) do
    amount =
      case Map.get(attrs, "amount") do
        amount when is_binary(amount) -> String.to_integer(amount)
        amount -> amount
      end

    currency = Map.get(attrs, "currency")

    price =
      case {amount, currency} do
        {nil, _} -> nil
        {_, nil} -> nil
        {a, c} -> Money.new(a, c)
      end

    attrs
    |> Map.put("price", price)
    |> Map.drop(["amount", "currency"])
  end

  def maybe_update_price(params, %Expense{price: existing_price}) do
    new_amount = Map.get(params, "amount", existing_price.amount)
    new_currency = Map.get(params, "currency", existing_price.currency)

    {new_amount, new_currency}
    |> update_price_if_changed(existing_price)
    |> update_params_with_price(params)
  end

  defp update_price_if_changed({new_amount, new_currency}, %Money{
         amount: existing_amount,
         currency: existing_currency
       }) do
    if new_amount != existing_amount or new_currency != existing_currency do
      try do
        {:ok, Money.new(new_amount, new_currency)}
      rescue
        _ -> {:error, "Invalid currency or amount"}
      end
    else
      {:ok, nil}
    end
  end

  defp update_params_with_price({:ok, nil}, params), do: params
  defp update_params_with_price({:ok, new_price}, params), do: Map.put(params, "price", new_price)
  defp update_params_with_price({:error, _}, params), do: Map.put(params, "price", "invalid")
end
