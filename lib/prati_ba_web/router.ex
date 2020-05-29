defmodule PratiBaWeb.Router do
  use PratiBaWeb, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PratiBaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :tracking do
    plug PratiBaWeb.Plugs.RequestTracker
  end

  pipeline :admin do
    plug :basic_auth, username: "pratiba", password: System.get_env("ADMIN_PASSWORD") || "pratiba"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  resources "/health", PratiBaWeb.HealthController, only: [:index]

  scope "/admin", PratiBaWeb do
    pipe_through [:browser, :admin]

    resources "/", AdminController, only: [:index]
    live_dashboard "/dashboard", metrics: Telemetry
  end

  scope "/", PratiBaWeb do
    pipe_through [:browser, :tracking]

    resources "/", ArticleController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PratiBaWeb do
  #   pipe_through :api
  # end
end
