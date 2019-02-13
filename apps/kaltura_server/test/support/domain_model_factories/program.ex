defmodule KalturaServer.DomainModelFactories.Program do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.Program

  def default_attrs do
    %{
      id: next_table_id(),
      name: Faker.Lorem.word(),
      epg_id: "p_epg_#{:rand.uniform(10000)}",
      tv_stream_id: nil
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.Program.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.Program.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{tv_stream_id: nil} = write_attrs ->
            %{id: tv_stream_id} = Factory.insert(:tv_stream)

            write_attrs
            |> Map.put(:tv_stream_id, tv_stream_id)

          write_attrs ->
            write_attrs
        end).()
  end
end
