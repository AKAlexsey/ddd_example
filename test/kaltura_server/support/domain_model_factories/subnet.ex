defmodule CtiKaltura.DomainModelFactories.Subnet do
  @moduledoc false

  use CtiKaltura.DomainModelFactories.AbstractFactory, table: DomainModel.Subnet
  import DomainModel, only: [cidr_fields_for_search: 1]

  def default_attrs do
    %{
      id: next_table_id(),
      name: Faker.Lorem.word(),
      cidr: "#{Faker.Internet.ip_v4_address()}/31",
      region_id: nil,
      server_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.Subnet.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.Subnet.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn %{cidr: cidr} = write_attrs -> Map.merge(write_attrs, cidr_fields_for_search(cidr)) end).()
    |> (fn
          %{region_id: nil} = write_attrs ->
            %{id: region_id} = Factory.insert(:region)
            Map.put(write_attrs, :region_id, region_id)

          write_attrs ->
            write_attrs
        end).()
  end
end
