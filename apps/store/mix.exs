defmodule Store.Mixfile do
  use Mix.Project

  def project do
    [
      app: :store,
      version: "4.1.9",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: [main: "Store"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger], mod: {Store.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 3.0.7"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.14.1"},
      {:scrivener_ecto, "~> 2.0"},
      {:comeonin, "~> 3.2.0"},
      {:poison, "~> 3.0"},
      {:httpoison, "~> 1.4.0"},
      {:hackney, "~> 1.9.0"},
      {:timex, "~> 3.3.0"},
      {:geo_postgis, "~> 2.1.0"},
      {:gen_smtp, "~> 0.13.0"},
      {:swoosh, "~> 0.21"},
      # {:credo, "~> 0.3.10", only: [:dev, :test]},
      # {:dialyxir, "~> 0.3.3", only: [:dev, :test]},
      {:calendar, "~> 0.17.4"},
      {:html_sanitize_ex, "~> 1.3.0"},
      {:hashids, "~> 2.0.4"},
      {:quantum, "~> 2.3.4"},
      {:csv, "~> 2.1.1"},
      {:ex_machina, "~> 2.1", only: :test},
      {:timber, "~> 3.1"},
      {:timber_exceptions, "~> 2.1"},
      {:timber_ecto, "~> 2.1"},
      {:pigeon, "~> 1.2.3"},
      {:kadabra, "~> 0.4.3"},
      {:tesla, "~> 1.2.0"},
      {:zxcvbn, "~> 0.1.3"},
      {:ex_money, "~> 3.4"},
      {:jason, "~> 1.0"},
      {:argon2_elixir, "~> 1.3"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
