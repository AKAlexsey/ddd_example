defmodule KalturaServer.Caching.Region do
  @moduledoc """
  Module contains logic for:
  * Initializing mnesia table
  * Writing data from database to mnesia repo
  * Finding appropriate data for client
  """

  @table __MODULE__
  @table_attributes [:id, :name, :description, :status]

  def init_table do
    :mnesia.create_table(
      @table,
      attributes: @table_attributes,
      type: :ordered_set,
      disc_copies: [node()]
    )
  end

  def write(attributes) do
    :mnesia.transaction(fn ->
      :mnesia.write(make_table_attributes(attributes))
    end)
  end

  defp make_table_attributes(attributes) do
    [@table] ++ Enum.map(@table_attributes, fn attr -> Map.get(attributes, attr, nil) end)
    |> List.to_tuple()
  end
end
