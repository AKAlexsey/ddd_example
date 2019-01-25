defmodule CtiKaltura.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      apps: [:kaltura_admin, :kaltura_server],
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:plug_cowboy, "~> 1.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:faker, "~> 0.11", only: [:dev, :test]},
      # Tools
      {:cidr, ">= 1.1.0"},
      {:yaml_elixir, "~> 2.1"},
      # Testing
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
