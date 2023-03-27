defmodule PratiBaWeb.Router do
  use PratiBaWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PratiBaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :analytics do
    plug PratiBaWeb.Plugs.Analytics
  end

  pipeline :admin do
    plug :put_root_layout, html: {PratiBaWeb.Layouts, :admin_root}
    plug :admin_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  resources "/health", PratiBaWeb.HealthController, only: [:index]

  scope "/admin", PratiBaWeb do
    pipe_through [:browser, :admin]

    resources "/", AdminController, only: [:index]
    live_dashboard "/dashboard", metrics: PratiBaWeb.Telemetry
    live "/analytics", AnalyticsLive.Index, :index
  end

  scope "/", PratiBaWeb do
    pipe_through [:browser, :analytics]

    live "/", ArticleLive.Index, :index
    resources "/", ArticleController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PratiBaWeb do
  #   pipe_through :api
  # end

  defp admin_auth(conn, _opts) do
    options = Application.get_env(:prati_ba, :admin_auth)
    username = Keyword.fetch!(options, :username)
    password = Keyword.fetch!(options, :password)

    with {request_username, request_password} <- Plug.BasicAuth.parse_basic_auth(conn),
         valid_username? = Plug.Crypto.secure_compare(username, request_username),
         valid_password? = Plug.Crypto.secure_compare(password, request_password),
         true <- valid_username? and valid_password? do
      conn
    else
      _ -> conn |> Plug.BasicAuth.request_basic_auth() |> halt()
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
