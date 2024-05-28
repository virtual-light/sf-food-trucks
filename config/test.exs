import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mobile_food, MobileFoodWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HT08Nne1zsdyd2ifIn/CVg8dH49tvFbt0oamHW6x9PJp4TQF1aQjX90xNj+pg00u",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
