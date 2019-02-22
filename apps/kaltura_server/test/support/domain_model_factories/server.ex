defmodule KalturaServer.DomainModelFactories.Server do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.Server

  def default_attrs do
    %{
      id: next_table_id(),
      domain_name: Faker.Lorem.word(),
      healthcheck_enabled: true,
      ip: Faker.Internet.ip_v4_address(),
      port: 81,
      prefix: "edge#{:rand.uniform(10)}",
      status: :active,
      type: :edge,
      weight: 5,
      server_group_ids: [],
      program_record_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.Server.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.Server.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{server_group_ids: []} = write_attrs ->
            %{id: server_group_id} = Factory.insert(:server_group)

            write_attrs
            |> Map.put(:server_group_ids, [server_group_id])

          write_attrs ->
            write_attrs
        end).()
  end
end
