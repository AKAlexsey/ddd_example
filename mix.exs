defmodule CtiKaltura.MixProject do
  use Mix.Project

  def project do
    [
      app: :cti_kaltura,
      version: "1.0.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "1.6.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() in [:prod, :stage],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {CtiKaltura, []},
      extra_applications: [
        :logger,
        :libcluster,
        :amnesia,
        :runtime_tools,
        :plug_cowboy,
        :phoenix_ecto,
        :edeliver,
        :soap
      ]
    ]
  end

  defp elixirc_paths(:test),
    do: ["lib", "priv", "web", "test/kaltura_admin/support", "test/kaltura_server/support"]

  defp elixirc_paths(:dev), do: ["lib", "priv", "web", "test/kaltura_admin/support"]
  defp elixirc_paths(:prod), do: ["lib", "priv", "web"]
  defp elixirc_paths(_), do: ["lib", "priv", "web", "test/kaltura_admin/support"]

  defp deps do
    [
      # Base
      {:phoenix, "~> 1.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      # Database
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_observable, "~> 0.3.1"},
      {:amnesia, "~> 0.2.7"},
      # Quality assurance
      {:benchee, "~> 0.11", only: :dev},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:faker, "~> 0.11"},
      # Clustering
      # {:syn, "~> 1.6"}, # Закомментировано т.к. пока нет необходимости использовать SYN, достаточно :global
      {:libcluster, "~> 3.0"},
      {:individual, "~> 0.2.1"},
      # Authorization
      {:comeonin, "~> 4.0"},
      {:argon2_elixir, "~> 1.2"},
      {:guardian, "~> 1.0"},
      # Logging
      {:logger_file_backend, "~> 0.0.10"},
      # Tools
      {:cidr, ">= 1.1.0"},
      {:yaml_elixir, "~> 2.1"},
      {:phoenix_html, "~> 2.12.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:sweet_xml, "~> 0.6"},
      # {:soap, "~> 1.0"},
      {:soap, git: "https://github.com/CarefreeSlacker/soap.git", branch: "add-nested-types"},
      # Testing
      {:mock, "~> 0.3.0", only: :test},
      # Deployment
      {:edeliver, "~> 1.5.2"},
      {:distillery, "~> 1.5.2", runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
