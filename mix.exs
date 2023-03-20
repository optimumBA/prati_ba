defmodule PratiBa.MixProject do
  use Mix.Project

  def project do
    [
      app: :prati_ba,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PratiBa.Application, []},
      extra_applications: [:logger, :os_mon, :runtime_tools]
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
      {:phoenix, "~> 1.6.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:mojito, "~> 0.7.12"},
      {:bypass, "~> 2.1", only: :test},
      {:fast_rss, github: "almirsarajcic/fast_rss", branch: "rustler-0.25"},
      {:timex, "~> 3.7"},
      {:feeder_ex, "~> 1.1"},
      {:tzdata, "~> 1.1.1"},
      {:ecto_fields, "~> 1.3.0"},
      {:ex_machina, "~> 2.7", only: :test},
      {:waffle, "~> 1.1.6"},
      {:waffle_ecto, "~> 0.0.11"},
      {:quantum, "~> 3.5"},
      {:mox, "~> 1.0", only: :test},
      {:html_entities, "~> 0.5"},
      {:remote_ip, "~> 1.0"},
      {:html_sanitize_ex, "~> 1.4"},
      {:timber, "~> 3.1"},
      {:timber_ecto, "~> 2.1"},
      {:timber_plug, "~> 1.1"},
      {:geolix, "~> 2.0"},
      {:geolix_adapter_mmdb2, "~> 0.6"},
      {:ua_inspector, "~> 3.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev}
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
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ],
      prettier: ["cmd --cd assets npx prettier -w .."]
    ]
  end
end
