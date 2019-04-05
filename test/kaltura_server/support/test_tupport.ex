defmodule CtiKaltura.MnesiaTestSupport do
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
      |> Enum.each(&flush_table/1)
    end)
  end

  defp flush_table(table) do
    Amnesia.Table.foldl(table, [], fn record, acc ->
      acc ++ [elem(record, 1)]
    end)
    |> Enum.each(fn id ->
      table.delete(id)
    end)
  end
end
