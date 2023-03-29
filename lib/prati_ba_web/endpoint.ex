defmodule PratiBaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :prati_ba

  if Application.compile_env(:prati_ba, :env) == :prod do
    plug RemoteIp, headers: ~w[fly-client-ip]
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    max_age: 10 * 365 * 24 * 60 * 60,
    key: "_prati_ba_session",
    signing_salt: "pRGp8JdR"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    longpoll: true,
    websocket: [connect_info: [session: @session_options]]

  socket "/socket", PratiBaWeb.UserSocket,
    longpoll: true,
    websocket: true

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :prati_ba,
    gzip: false,
    only: PratiBaWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :prati_ba
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug Timber.Plug.HTTPContext
  plug Timber.Plug.Event
  plug PratiBaWeb.Router
end
