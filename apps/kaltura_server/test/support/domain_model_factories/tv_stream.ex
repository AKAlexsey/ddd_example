defmodule KalturaServer.DomainModelFactories.TvStream do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.TvStream

  def default_attrs do
    %{
      id: next_table_id(),
      stream_path: Faker.Lorem.word(),
      status: "ACTIVE",
      protocol: "HLS",
      encryption: "NONE",
      linear_channel_id: nil,
      complex_search_index: {}
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.TvStream.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.TvStream.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> put_complex_search_index()
  end

  defp put_complex_search_index(
         %{linear_channel_id: nil, status: status, protocol: protocol} = write_attrs
       ) do
    %{id: linear_channel_id, epg_id: epg_id} = Factory.insert(:linear_channel)

    write_attrs
    |> Map.merge(%{
      linear_channel_id: linear_channel_id,
      complex_search_index: {epg_id, status, protocol}
    })
  end

  defp put_complex_search_index(
         %{linear_channel_id: id, status: status, protocol: protocol} = write_attrs
       ) do
    %{epg_id: epg_id} = Amnesia.transaction(fn -> DomainModel.LinearChannel.read(id) end)

    write_attrs
    |> Map.put(:complex_search_index, {epg_id, status, protocol})
  end
end
