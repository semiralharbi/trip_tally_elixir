defmodule TripTally.Money do
  @moduledoc """
  This module holds helpers for Money
  """

  alias TripTally.Expenses.Expense
  alias TripTally.Trips.Trip

  def create_price(attrs, price_field) do
    price_attrs = Map.get(attrs, price_field, %{})

    amount = parse_amount(price_attrs["amount"])
    currency = price_attrs["currency"]

    price =
      case {amount, currency} do
        {nil, _} -> nil
        {_, nil} -> nil
        {a, c} -> Money.new(a, c)
      end

    attrs
    |> Map.put(price_field, price)
  end

  defp parse_amount(amount) when is_binary(amount), do: convert_binary_to_float(amount)
  defp parse_amount(amount) when is_float(amount), do: round(amount * 100)
  defp parse_amount(amount) when is_integer(amount), do: round(amount * 100)
  defp parse_amount(_), do: nil

  def maybe_update_price(%Expense{price: existing_price}, %{"price" => params} = attrs) do
    case params do
      nil ->
        attrs

      %{"amount" => _, "currency" => _} ->
        new_amount = parse_amount_types(params, existing_price.amount)
        new_currency = Map.get(params, "currency", existing_price.currency)

        {new_amount, new_currency}
        |> update_price_if_changed(existing_price)
        |> update_params_with_price(params, "price")
    end
  end

  def maybe_update_price(%Trip{planned_cost: existing_price}, %{"planned_cost" => params} = attrs) do
    case params do
      nil ->
        attrs

      %{"amount" => _, "currency" => _} ->
        new_amount = parse_amount_types(params, existing_price.amount)
        new_currency = Map.get(params, "currency", existing_price.currency)

        {new_amount, new_currency}
        |> update_price_if_changed(existing_price)
        |> update_params_with_price(attrs, "planned_cost")
    end
  end

  def maybe_update_price(_entity, attrs), do: attrs

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
      amount when is_binary(amount) -> convert_binary_to_float(amount)
      amount when is_float(amount) -> round(amount * 100)
      amount -> amount
    end
  end

  defp update_params_with_price({:ok, nil}, params, _price_field), do: params

  defp update_params_with_price({:ok, new_price}, params, price_field),
    do: Map.put(params, price_field, new_price)

  defp update_params_with_price({:error, _}, params, price_field),
    do: Map.put(params, price_field, "invalid")

  defp convert_binary_to_float(amount) do
    case Regex.match?(~r/^\d+$/, amount) do
      true ->
        amount = String.to_float(amount <> ".0")
        round(amount * 100)

      false ->
        case Regex.match?(~r/^\d+\.\d+$/, amount) do
          true ->
            amount = String.to_float(amount)
            round(amount * 100)

          false ->
            {:error, "Invalid amount format"}
        end
    end
  end

  def convert_to_decimal_amount(data) when is_list(data) do
    Enum.map(data, &convert_single_to_decimal/1)
  end

  def convert_to_decimal_amount(data) do
    convert_single_to_decimal(data)
  end

  defp convert_single_to_decimal(%{expenses: _expenses} = trip) do
    trip
    |> convert_amount_field_to_decimal(:planned_cost)
    |> Map.update(:expenses, [], &convert_expenses_to_decimal/1)
  end

  defp convert_single_to_decimal(expense) do
    convert_amount_field_to_decimal(expense, :price)
  end

  defp convert_expenses_to_decimal(expenses) do
    Enum.map(expenses, &convert_amount_field_to_decimal(&1, :price))
  end

  defp convert_amount_field_to_decimal(struct, field) do
    Map.update(struct, field, %{}, fn field_value ->
      Map.update(field_value, :amount, Decimal.new(0), fn amount ->
        amount
        |> Decimal.div(Decimal.new(100))
      end)
    end)
  end
end
