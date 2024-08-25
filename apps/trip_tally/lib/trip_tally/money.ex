defmodule TripTally.Money do
  @moduledoc """
  This module holds helpers for Money
  """

  alias TripTally.Expenses.Expense
  alias TripTally.Trips.Trip

  def create_price(attrs, price_field) do
    amount =
      case Map.get(attrs, "amount") do
        amount when is_binary(amount) ->
          String.to_integer(amount) |> Kernel.*(100) |> round()

        amount when is_float(amount) ->
          amount |> Kernel.*(100) |> round()

        amount when is_integer(amount) ->
          amount |> Kernel.*(100) |> round()

        _ ->
          nil
      end

    currency = Map.get(attrs, "currency")

    price =
      case {amount, currency} do
        {nil, _} -> nil
        {_, nil} -> nil
        {a, c} -> Money.new(a, c)
      end

    attrs
    |> Map.put(price_field, price)
    |> Map.drop(["amount", "currency"])
  end

  def maybe_update_price(%Expense{price: existing_price}, params) do
    new_amount = parse_amount_types(params, existing_price.amount)
    new_currency = Map.get(params, "currency", existing_price.currency)

    {new_amount, new_currency}
    |> update_price_if_changed(existing_price)
    |> update_params_with_price(params, "price")
  end

  def maybe_update_price(%Trip{planned_cost: existing_price}, params) do
    new_amount = parse_amount_types(params, existing_price.amount)

    new_currency = Map.get(params, "currency", existing_price.currency)

    {new_amount, new_currency}
    |> update_price_if_changed(existing_price)
    |> update_params_with_price(params, "planned_cost")
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

  defp parse_amount_types(params, existing_price_amount) do
    case Map.get(params, "amount", existing_price_amount) do
      amount when is_binary(amount) -> String.to_integer(amount)
      amount when is_float(amount) -> round(amount * 100)
      amount -> amount
    end
  end

  defp update_params_with_price({:ok, nil}, params, _price_field), do: params

  defp update_params_with_price({:ok, new_price}, params, price_field),
    do: Map.put(params, price_field, new_price)

  defp update_params_with_price({:error, _}, params, price_field),
    do: Map.put(params, price_field, "invalid")
end
