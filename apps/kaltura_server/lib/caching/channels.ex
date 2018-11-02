defmodule KalturaServer.Caching.Channels do
  @moduledoc """
  Module contains logic for:
  * Initializing mnesia table
  * Writing data from database to mnesia repo
  * Finding appropriate data for client
  """

  @table __MODULE__

  def init_table do
    :mnesia.create_table(
      @table,
      attributes: [:channel, :url]
    )
  end

  def write(channel, url) do
    :mnesia.transaction(fn ->
      :mnesia.write({@table, channel, url})
    end)
  end

  @spec find_channel_url(binary) :: {:ok, binary} | {:error, :not_found}
  def find_channel_url(channel) do
    case :mnesia.transaction(fn -> :mnesia.read(@table, channel) end) do
      {:atomic, [{@table, _, url}]} ->
        {:ok, url}
      _ ->
        {:error, :not_found}
    end
  end
end
