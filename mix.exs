defmodule PratiBa.MixProject do
  use Mix.Project

  def project do
    [
      app: :prati_ba,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        prati_ba: [
          include_executables_for: [:unix],
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PratiBa.Application, []},
      extra_applications: [:inets, :logger, :os_mon, :runtime_tools, :timex, :ssl, :xmerl]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.1"},
      {:phoenix_ecto, "~> 4.1"},
      {:plug, github: "almirsarajcic/plug", branch: "exclude-tuple", override: true},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.12.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:mojito, "~> 0.6.1"},
      {:bypass, "~> 1.0", only: :test},
      {:fast_rss, "~> 0.3.0"},
      {:timex, github: "almirsarajcic/timex", branch: "bosnian-translations"},
      {:feeder_ex, "~> 1.1"},
      {:tzdata, "~> 1.0.3"},
      {:ecto_fields, "~> 1.2.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:waffle, "~> 1.1.0"},
      {:waffle_ecto, "~> 0.0.9"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:quantum, "~> 3.0-rc"},
      {:mox, "~> 0.5", only: :test},
      {:html_entities, "~> 0.5"},
      {:geolix, "~> 1.0"},
      {:geolix_adapter_mmdb2, "~> 0.4.0"},
      {:ua_inspector, "~> 2.0"},
      {:libcluster, "~> 3.2"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
