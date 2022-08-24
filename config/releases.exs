import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :prati_ba, PratiBa.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  socket_options: [:inet6]

host =
  System.get_env("PHX_HOST") ||
    raise """
    environment variable PHX_HOST is missing.
    For example: prati.ba
    """

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :prati_ba, PratiBaWeb.Endpoint,
  server: true,
  http: [
    # Enable IPv6 and bind on all interfaces.
    # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
    # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
    # for details about using IPv6 vs IPv4 and loopback vs public addresses.
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: secret_key_base,
  url: [scheme: "https", host: host, port: 443]

admin_password =
  System.get_env("ADMIN_PASSWORD") ||
    raise """
    environment variable ADMIN_PASSWORD is missing.
    """

config :prati_ba,
  admin_auth: [
    username: "pratiba",
    password: admin_password
  ],
  ssl_excluded_hosts: ["localhost"]

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
      source:
        "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=#{maxmind_license_key}&suffix=tar.gz"
    },
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source:
        "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=#{maxmind_license_key}&suffix=tar.gz"
    }
  ]

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "/data"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :prati_ba, PratiBaWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
