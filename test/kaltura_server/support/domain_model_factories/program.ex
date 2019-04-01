defmodule CtiKaltura.DomainModelFactories.Program do
  @moduledoc false

  use CtiKaltura.DomainModelFactories.AbstractFactory, table: DomainModel.Program

  def default_attrs do
    %{
      id: next_table_id(),
      name: Faker.Lorem.word(),
      epg_id: "p_epg_#{:rand.uniform(10000)}",
      linear_channel_id: nil
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
          %{linear_channel_id: nil} = write_attrs ->
            %{id: linear_channel_id} = Factory.insert(:linear_channel)

            write_attrs
            |> Map.put(:linear_channel_id, linear_channel_id)

          write_attrs ->
            write_attrs
        end).()
  end
end
