defmodule Growio.MixProject do
  use Mix.Project

  def project do
    [
      app: :growio,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {Growio.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:dns_cluster, "0.1.3"},
      {:phoenix_pubsub, "2.1.3"},
      {:ecto_sql, "3.11.1"},
      {:postgrex, "0.17.4"},
      {:jason, "1.4.1"},
      {:swoosh, "1.15.2"},
      {:finch, "0.18.0"},
      {:nebulex, "2.6.1"},
      {:shards, "1.1.0"},
      {:decimal, "2.1.1"},
      {:phoenix, "1.7.12"},
      {:phoenix_ecto, "4.5.1"},
      {:telemetry_metrics, "0.6.2"},
      {:telemetry_poller, "1.0.0"},
      {:gettext, "0.24.0"},
      {:plug_cowboy, "2.7.1"},
      {:bandit, "1.5.0"},
      {:open_api_spex, "3.18.3"},
      {:corsica, "2.1.3"},
      {:hackney, "1.20.1"},
      {:telegram, github: "visciang/telegram", tag: "1.2.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "run priv/repo/seeds.exs",
        "test"
      ]
    ]
  end
end
