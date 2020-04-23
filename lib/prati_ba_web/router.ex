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
    plug PratiBaWeb.Plugs.RequestTracker
  end

  pipeline :admin do
    plug :basic_auth, username: "pratiba", password: System.get_env("ADMIN_PASSWORD") || "pratiba"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PratiBaWeb do
    pipe_through :browser

    resources "/", ArticleController, only: [:index, :show]
  end

  scope "/admin" do
    pipe_through [:browser, :admin]

    live_dashboard "/dashboard", metrics: PratiBaWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  # scope "/api", PratiBaWeb do
  #   pipe_through :api
  # end
end
