defimpl Jason.Encoder, for: Money do
  def encode(%Money{amount: amount, currency: currency}, opts) do
    Jason.Encode.map(%{amount: amount, currency: to_string(currency)}, opts)
  end
end
