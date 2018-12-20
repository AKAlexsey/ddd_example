defmodule KalturaServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :kaltura_server,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:plug_cowboy],
      mod: {KalturaServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, umbrella: true},
      {:amnesia, "~> 0.2.7"},
      {:kaltura_admin, in_umbrella: true}
    ]
  end
end
