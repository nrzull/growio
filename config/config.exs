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
config :growio,
  ecto_repos: [Growio.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :growio, Growio.Mailer, adapter: Swoosh.Adapters.Local

config :growio_web,
  ecto_repos: [Growio.Repo],
  generators: [context_app: :growio],
  jwt_secret: "jwt_secret",
  ws_secret: "ws_secret"

# Configures the endpoint
config :growio_web, GrowioWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    view: GrowioWeb.Views.JSON,
    accepts: ~w(json),
    layout: false
  ],
  pubsub_server: Growio.PubSub,
  live_view: [signing_salt: "OhfIZA6C"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :growio_web, :cors,
  origins: [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:3001",
    "http://127.0.0.1:3001"
  ],
  allow_credentials: true,
  allow_headers: :all

config :growio, Growio.Cache,
  gc_interval: :timer.hours(1),
  backend: :shards,
  partitions: 2

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :growio_telegram, market_url: "http://localhost:3001"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
