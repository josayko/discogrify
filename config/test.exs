import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :discogrify, Discogrify.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "discogrify_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :discogrify, DiscogrifyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "g70gpCphGdohU0SlBsb3ujNJPf13Gra51r7s2UqZsMOyPCm6H6zV0d7KBQ9/MnjV",
  server: false

# In test we don't send emails
config :discogrify, Discogrify.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Spotify API for tests (using dummy values)
config :discogrify,
  spotify_accounts_url: "https://accounts.spotify.com",
  spotify_api_url: "https://api.spotify.com/v1",
  spotify_client_id: "test_client_id",
  spotify_client_secret: "test_client_secret"
