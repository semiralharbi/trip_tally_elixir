defmodule TripTally.Utils.DateParser do
  def parse_date(date_string) do
    formats = [
      "{0D}-{0M}-{YYYY}",
      "{YYYY}-{0M}-{0D}",
      "{0M}-{0D}-{YYYY}",
      "{0D}/{0M}/{YYYY}",
      "{YYYY}/{0M}/{0D}",
      "{0M}/{0D}/{YYYY}",
      "{0M}.{0D}.{YYYY}",
      "{0D}.{0M}.{YYYY}",
      "{YYYY}.{0M}.{0D}",
      "{YYYYMMDD}",
      "{0D} {Mfull} {YYYY}",
      "{Mfull} {0D}, {YYYY}",
      "{0D}-{Mshort}-{YYYY}",
      "{Mshort}-{0D}-{YYYY}",
      "{0D}/{Mshort}/{YYYY}"
    ]

    Enum.find_value(formats, fn format ->
      case Timex.parse(date_string, format) do
        {:ok, datetime} -> {:ok, Timex.to_date(datetime)}
        _ -> nil
      end
    end) || {:error, :invalid_format}
  end

  def normalize_date(attrs, field) do
    case Map.get(attrs, field) do
      nil ->
        attrs

      date when is_binary(date) ->
        case parse_date(date) do
          {:ok, dt} -> Map.put(attrs, field, dt)
          {:error, _} -> attrs
        end

      date when is_integer(date) ->
        dt = DateTime.from_unix!(date, :second) |> DateTime.to_date()
        Map.put(attrs, field, dt)

      _ ->
        attrs
    end
  end
end
