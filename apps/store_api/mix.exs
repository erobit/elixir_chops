defmodule StoreAPI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :store_api,
      version: "4.1.9",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {StoreAPI.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:store, in_umbrella: true},
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.1.0"},
      {:phoenix_html, "~> 2.12.0"},
      {:gettext, "~> 0.16.0"},
      {:plug_cowboy, "~> 1.0"},
      {:absinthe, "~> 1.4.13"},
      {:absinthe_plug, "~> 1.4.5"},
      {:absinthe_ecto, "~> 0.1.3"},
      {:poison, "~> 3.0"},
      {:comeonin, "~> 3.2.0"},
      {:guardian, "~> 1.1.1"},
      {:cors_plug, "~> 1.5.2"},
      {:oauth2, "~> 0.9.3"},
      {:csv, "~> 2.1.1"},
      {:floki, "~> 0.28.0"}
    ]
  end
end
