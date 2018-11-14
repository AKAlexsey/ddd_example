defmodule KalturaServer.ChannelHandler do
  @moduledoc """
  Handle events from external sources.
  """

  alias KalturaServer.Caching.Channels

  def handle(:channel_updated, %{name: name, url: url}) do
    Channels.write(name, url)
  end

  def handle(message, params) do
    IO.puts("!!! undefined message #{inspect(message)} #{inspect(params)}")
  end
end
