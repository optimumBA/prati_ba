# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL")# ||
    # raise """
    # environment variable DATABASE_URL is missing.
    # For example: ecto://USER:PASS@HOST/DATABASE
    # """

config :prati_ba, PratiBa.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE")# ||
    # raise """
    # environment variable SECRET_KEY_BASE is missing.
    # You can generate one by calling: mix phx.gen.secret
    # """

config :prati_ba, PratiBaWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

maxmind_license_key =
  System.get_env("MAXMIND_LICENSE_KEY")# ||
    # raise """
    # environment variable MAXMIND_LICENSE_KEY is missing.
    # For example: 4FMnz1Pr2Cxnd6BR
    # """

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

aws_s3_bucket =
  System.get_env("AWS_S3_BUCKET")# ||
    # raise """
    # environment variable AWS_S3_BUCKET is missing.
    # For example: static.prati.ba
    # """

asset_host =
  System.get_env("ASSET_HOST")# ||
    # raise """
    # environment variable ASSET_HOST is missing.
    # For example: https://static.prati.ba
    # """

config :waffle,
  storage: Waffle.Storage.S3,
  storage_dir_prefix: "",
  bucket: aws_s3_bucket,
  asset_host: asset_host

aws_s3_id =
  System.get_env("AWS_S3_ID")# ||
    # raise """
    # environment variable AWS_S3_ID is missing.
    # For example: AKIB2GHLQBL82IVL1B4N
    # """

aws_s3_secret =
  System.get_env("AWS_S3_SECRET")# ||
    # raise """
    # environment variable AWS_S3_SECRET is missing.
    # For example: 1qyPY8F93ZW4B2gHy1eR/U9BL2zqb3c0LB3CV4hV
    # """

config :ex_aws,
  json_codec: Jason,
  access_key_id: aws_s3_id,
  secret_access_key: aws_s3_secret,
  region: "eu-central-1",
  s3: [
    scheme: "https://",
    host: "s3.eu-central-1.amazonaws.com",
    region: "eu-central-1"
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
