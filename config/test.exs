use Mix.Config

# Configure your database
config :prati_ba, PratiBa.Repo,
  username: "postgres",
  password: "postgres",
  database: "prati_ba_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :prati_ba, PratiBaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
