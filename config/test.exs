use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cti_kaltura, CtiKaltura.Endpoint,
  http: [port: 4002],
  server: false

# Timeout in milliseconds
config :cti_kaltura, after_start_callback_timeout: 50

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cti_kaltura, CtiKaltura.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cti_kaltura_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
