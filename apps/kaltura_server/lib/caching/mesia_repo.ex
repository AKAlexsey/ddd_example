defmodule KalturaServer.Caching.MnesiaRepo do
  @moduledoc """
  Bag for all cachin tables in project
  """

  alias KalturaServer.Caching.Channels
  alias CtiKaltura.Seeds
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    :mnesia.start()

    Channels.init_table()

    init_channels()

    {:ok, []}
  end

  defp init_channels do
    Seeds.channel_urls()
    |> Enum.each(fn {channel, url} -> Channels.write(channel, url) end)
  end
end
