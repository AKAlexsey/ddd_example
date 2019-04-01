defmodule CtiKaltura.DomainModelFactories.ProgramRecord do
  @moduledoc false

  use CtiKaltura.DomainModelFactories.AbstractFactory, table: DomainModel.ProgramRecord

  def default_attrs do
    %{
      id: next_table_id(),
      program_id: nil,
      server_id: nil,
      status: "COMPLETED",
      protocol: "HLS",
      encryption: "NONE",
      path: "#{Faker.Lorem.word()}",
      prefix: "#{Faker.Lorem.word()}"
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
    |> put_server_data()
    |> put_program_data()
  end

  defp put_server_data(%{server_id: nil} = write_attrs) do
    %{id: server_id, prefix: prefix} = Factory.insert(:server)

    write_attrs
    |> Map.merge(%{
      server_id: server_id,
      prefix: prefix
    })
  end

  defp put_server_data(%{server_id: server_id} = write_attrs) do
    %{prefix: prefix} = Amnesia.transaction(fn -> DomainModel.Server.read(server_id) end)

    write_attrs
    |> Map.put(:prefix, prefix)
  end

  defp put_program_data(%{program_id: nil, status: status, protocol: protocol} = write_attrs) do
    %{id: program_id, epg_id: epg_id} = Factory.insert(:program)

    write_attrs
    |> Map.merge(%{
      program_id: program_id,
      complex_search_index: {epg_id, status, protocol}
    })
  end

  defp put_program_data(
         %{program_id: program_id, status: status, protocol: protocol} = write_attrs
       ) do
    %{epg_id: epg_id} = Amnesia.transaction(fn -> DomainModel.Program.read(program_id) end)

    write_attrs
    |> Map.put(:complex_search_index, {epg_id, status, protocol})
  end
end
