defmodule KalturaServer.DomainModelFactories.ServerGroup do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.ServerGroup

  def default_attrs do
    %{
      id: next_table_id(),
      name: Faker.Lorem.word(),
      status: :active,
      server_ids: [],
      region_ids: [],
      tv_stream_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.ServerGroup.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.ServerGroup.write()
    end)
  end

  defp prepare_attrs(attrs) do
    Map.merge(default_attrs(), attrs)
  end
end
