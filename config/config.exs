# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :prati_ba,
  ecto_repos: [PratiBa.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :prati_ba, PratiBaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PratiBaWeb.ErrorHTML, json: PratiBaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PratiBa.PubSub,
  live_view: [signing_salt: "j359gYp6"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :prati_ba, PratiBa.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable non-UTC timezones
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Set Timex locale to Bosnian (Latin)
config :gettext, default_locale: "bs_latin"

user_agent = "Prati.ba (info@optimum.ba)"

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/static",
  headers: [{"User-Agent", user_agent}]

config :prati_ba, PratiBa.Scheduler,
  global: true,
  jobs: [
    # Every 5 minutes
    {"*/5 * * * *", {PratiBa.Scrapers, :fetch_new_articles, []}},
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

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
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
