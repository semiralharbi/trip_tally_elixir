# TripTally.Umbrella

# Local server configuration:

- Server runs on port 4000
- Run on your terminal (default value is `localhost`). This script will find your address IP and set it to local variable `PHX_HOST`

```sh
elixir apps/trip_tally_web/priv/scripts/local_ip.exs
```

- Run `mix deps.get`
- Run `mix phx.server` to start the server

# Other scripts

1. Exports all tables from DB to `csv` files:

```sh
elixir apps/trip_tally_web/priv/scripts/export_all_tables.exs
```
