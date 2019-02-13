defmodule KalturaServer.DomainModelFactories.ProgramRecord do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.ProgramRecord

  def default_attrs do
    %{
      id: next_table_id(),
      program_id: nil,
      server_id: nil,
      status: :planned,
      protocol: :HLS,
      path: "#{Faker.Lorem.word()}"
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.ProgramRecord.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.ProgramRecord.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{program_id: nil} = write_attrs ->
            %{id: program_id} = Factory.insert(:program)

            write_attrs
            |> Map.put(:program_id, program_id)

          write_attrs ->
            write_attrs
        end).()
    |> (fn
          %{server_id: nil} = write_attrs ->
            %{id: server_id} = Factory.insert(:server)

            write_attrs
            |> Map.put(:server_id, server_id)

          write_attrs ->
            write_attrs
        end).()
  end
end
