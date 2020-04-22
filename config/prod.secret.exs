# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :prati_ba, PratiBa.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :prati_ba, PratiBaWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

maxmind_license_key =
  System.get_env("MAXMIND_LICENSE_KEY") ||
    raise """
    environment variable MAXMIND_LICENSE_KEY is missing.
    For example: 4FMnz1Pr2Cxnd6BR
    """

config :geolix,
  databases: [
    %{
      id: :asn,
      adapter: Geolix.Adapter.MMDB2,
      source: "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=#{maxmind_license_key}&suffix=tar.gz",
    },
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=#{maxmind_license_key}&suffix=tar.gz",
    },
  ]

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :prati_ba, PratiBaWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
