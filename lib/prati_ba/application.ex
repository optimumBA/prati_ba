defmodule PratiBa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias PratiBa.ScrapingPipeline

  @impl true
  def start(_type, _args) do
    if Application.get_env(:prati_ba, :env) == :prod do
      :ok =
        :telemetry.attach(
          "timber-ecto-query-handler",
          [:prati_ba, :repo, :query],
          &Timber.Ecto.handle_event/4,
          log_level: :warn,
          query_time_ms_threshold: 1_000
        )
    end

    children = [
      # Start the Ecto repository
      PratiBa.Repo,
      # Start the Telemetry supervisor
      PratiBaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PratiBa.PubSub},
      # Start the Presence supervisor
      PratiBaWeb.Presence,
      # Start the Endpoint (http/https)
      PratiBaWeb.Endpoint,
      # Start a worker by calling: PratiBa.Worker.start_link(arg)
      # {PratiBa.Worker, arg}
      ScrapingPipeline
    ]

    children =
      case Application.get_env(:prati_ba, :env) do
        :dev ->
          children ++
            [
              PratiBa.Scheduler
            ]

        _ ->
          children
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PratiBa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PratiBaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
