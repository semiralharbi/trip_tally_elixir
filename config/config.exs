# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :trip_tally,
  ecto_repos: [TripTally.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :trip_tally, TripTally.Mailer, adapter: Swoosh.Adapters.Local

config :trip_tally_web,
  ecto_repos: [TripTally.Repo],
  generators: [context_app: :trip_tally, binary_id: true]

# Configures the endpoint
config :trip_tally_web, TripTallyWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST") || "localhost", port: 4000],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TripTallyWeb.ErrorHTML, json: TripTallyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TripTally.PubSub,
  live_view: [signing_salt: "MwnHPFbi"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  trip_tally_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/trip_tally_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  trip_tally_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/trip_tally_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
