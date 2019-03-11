defmodule KalturaAdmin.ServerFactory do
  alias KalturaAdmin.Repo
  alias KalturaAdmin.Servers.Server

  Faker.start()

  @maximum_port 65535

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
      status: :active,
      type: :edge,
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
