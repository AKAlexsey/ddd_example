defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  def handle(action, attrs) do
    IO.puts("!!!! RegionHandler #{action} #{inspect(attrs)}")
    :ok
  end
end
