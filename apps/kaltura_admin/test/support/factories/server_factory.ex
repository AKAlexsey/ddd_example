defmodule KalturaAdmin.ServerFactory do
  alias KalturaAdmin.Repo
  alias KalturaAdmin.Servers.Server

  Faker.start()

  @maximum_port 65535

  @default_attrs %{
    domain_name: Faker.Lorem.word(),
    healthcheck_enabled: true,
    healthcheck_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}}",
    ip: Faker.Internet.ip_v4_address(),
    manage_ip: Faker.Internet.ip_v4_address(),
    manage_port: :rand.uniform(@maximum_port),
    port: :rand.uniform(@maximum_port),
    prefix: "edge#{:rand.uniform(10)}}",
    status: :active,
    type: :edge,
    weight: 5
  }

  def build(attrs) do
    %Server{}
    |> Server.changeset(Map.merge(@default_attrs, attrs))
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
