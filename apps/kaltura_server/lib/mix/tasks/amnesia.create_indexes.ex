defmodule Mix.Tasks.Amnesia.CreateIndexes do
  @moduledoc false

  use Mix.Task

  @shortdoc "Adds indexes to tables schema in DomainModel"
  def run(_) do
    DomainModel.add_indexes()
    IO.puts("Indexes has been added")
  end
end
