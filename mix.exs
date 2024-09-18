defmodule PratiBa.MixProject do
  use Mix.Project

  def project do
    [
      app: :prati_ba,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: phoenix_deps() ++ optimum_deps() ++ app_deps(),

      # CI
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      preferred_cli_env: [
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test,
        sobelow: :test
      ],
      test_coverage: [tool: ExCoveralls],

      # Docs
      name: "PratiBa",
      source_url: "https://github.com/optimumBA/prati_ba",
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "main"
      ],

      # Release
      releases: [
        prati_ba: [
          include_executables_for: [:unix]
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
      extra_applications: [:logger, :os_mon, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp app_deps do
    []
  end

  defp optimum_deps do
    [
      {:appsignal_phoenix, "~> 2.3"},
      {:credo, "~> 1.7", only: :test, runtime: false},
      {:dialyxir, "~> 1.4", only: :test, runtime: false},
      {:doctest_formatter, "~> 0.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:ex_machina, "~> 2.7", only: :test},
      {:excoveralls, "~> 0.18", only: :test},
      {:faker, "~> 0.18", only: :test},
      {:github_workflows_generator, "~> 0.1", only: :dev, runtime: false},
      {:mix_audit, "~> 2.1", only: :test, runtime: false},
      {:sobelow, "~> 0.13", only: :test, runtime: false}
    ]
  end

  defp phoenix_deps do
    [
      {:phoenix, "~> 1.7.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:bypass, "~> 2.1", only: :test},
      {:fast_rss, github: "almirsarajcic/fast_rss", branch: "rustler-0.25"},
      {:timex, "~> 3.7"},
      {:feeder_ex, "~> 1.1"},
      {:tzdata, "~> 1.1.2"},
      {:ecto_fields, "~> 1.3.0"},
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
      {:gen_stage, "~> 1.1"},
      {:ua_inspector, "~> 3.0"}
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
      setup: [
        "deps.get",
        "cmd npm i -D prettier prettier-plugin-toml",
        "ecto.setup",
        "assets.setup",
        "assets.build"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind prati_ba", "esbuild prati_ba"],
      "assets.deploy": [
        "tailwind prati_ba --minify",
        "esbuild prati_ba --minify",
        "phx.digest"
      ],
      ci: [
        "deps.unlock --check-unused",
        "deps.audit",
        "hex.audit",
        "sobelow --config .sobelow-conf",
        "format --check-formatted",
        "cmd npx prettier -c .",
        "credo --strict",
        "dialyzer",
        "test --cover --warnings-as-errors"
      ],
      prettier: ["cmd npx prettier -w ."]
    ]
  end
end
