defmodule KalturaServer.TestSupport do
  @moduledoc """
  Contains helping functions for tests
  """

  require Amnesia
  require Amnesia.Helper

  @doc """
  !Use carefully! remove all records from mnesia tables
  """
  def flush_database_tables do
    Amnesia.transaction(fn ->
      DomainModel.tables()
      |> Enum.each(fn table ->
        Amnesia.Table.foldl(table, [], fn record, acc ->
          acc ++ [elem(record, 1)]
        end)
        |> Enum.each(fn id ->
          table.delete(id)
        end)
      end)
    end)
  end
end
