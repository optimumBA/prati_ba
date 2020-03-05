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
  render_errors: [view: PratiBaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PratiBa.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "dzeTtzQY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable non-UTC timezones
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# {:ok, %PratiBa.Articles.Article{} = article} = PratiBa.Articles.create_article(%{title: "Article Title", url: "nesto", published_at: ~N[2020-03-05 17:46:00]})

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
