defmodule TripTally.Repo do
  use Ecto.Repo,
    otp_app: :trip_tally,
    adapter: Ecto.Adapters.Postgres
end
