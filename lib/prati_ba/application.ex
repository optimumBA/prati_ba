defmodule PratiBa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PratiBa.Repo,
      # Start the Telemetry supervisor
      PratiBaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PratiBa.PubSub},
      # Start the Endpoint (http/https)
      PratiBaWeb.Endpoint
      # Start a worker by calling: PratiBa.Worker.start_link(arg)
      # {PratiBa.Worker, arg}
    ]

    children = case Application.get_env(:prati_ba, :env) do
      :prod -> children ++ [PratiBa.Scheduler]
      _ -> children
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PratiBa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PratiBaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
