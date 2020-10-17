# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :prati_ba,
  ecto_repos: [PratiBa.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :prati_ba, PratiBaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aZRUiAe1BkB34wrqtnlMV1JX4LElfMz+FjNMMIRDosqueX3jPQftfFefnLvh9V6L",
  render_errors: [view: PratiBaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PratiBa.PubSub,
  live_view: [signing_salt: "dzeTtzQY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable non-UTC timezones
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Set Timex locale to Bosnian (Latin)
config :timex, default_locale: "bs_latin"

user_agent = "Prati.ba (info@optimum.ba)"

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/static",
  headers: [{"User-Agent", user_agent}]

config :prati_ba, PratiBa.Scheduler,
  global: true,
  jobs: [
    # Every minute
    {"* * * * *", {PratiBa.Scrapers, :fetch_new_articles, []}},
    {"45 16 * * 5", {Geolix, :reload_databases, []}}
  ]

config :prati_ba,
  env: Mix.env(),
  admin_auth: [
    username: "pratiba",
    password: "pratiba"
  ],
  socket_salt: "GXtpirSt",
  user_agent: user_agent

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
