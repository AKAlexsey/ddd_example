defmodule CtiKaltura.ServerFactory do
  alias CtiKaltura.Repo
  alias CtiKaltura.Servers.Server

  Faker.start()

  @maximum_port 65_535

  def default_attrs(),
    do: %{
      domain_name:
        "#{Faker.Internet.domain_name()}#{:rand.uniform(10000)}#{:rand.uniform(10000)}",
      healthcheck_enabled: true,
      healthcheck_path: "/#{Faker.Lorem.word()}#{:rand.uniform(10000)}#{:rand.uniform(10000)}",
      ip: Faker.Internet.ip_v4_address(),
      manage_ip: Faker.Internet.ip_v4_address(),
      manage_port: :rand.uniform(@maximum_port),
      port: 80,
      prefix: "edge#{:rand.uniform(10000)}#{:rand.uniform(10000)}",
      status: "ACTIVE",
      type: "EDGE",
      weight: 5
    }

  def build(attrs) do
    %Server{}
    |> Server.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
