# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :mobile_food, namespace: MobileFood

# Configures the endpoint
config :mobile_food, MobileFoodWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MobileFoodWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MobileFood.PubSub,
  live_view: [signing_salt: "XW1TcbGz"]

config :mobile_food, :finch, client: Finch

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :objects_ids, :errors_data]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
