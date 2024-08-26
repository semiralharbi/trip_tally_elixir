defmodule TripTally.Repo do
  use Ecto.Repo,
    otp_app: :trip_tally,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
