defmodule KalturaServer.Handlers.DomainModelHandler do
  @moduledoc """
  Handle notifications after Create Update Delete actions with database.
  """
  alias KalturaServer.Handlers.AbstractHandler
  alias KalturaServer.DomainModelHandlers.RegionHandler

  @behaviour AbstractHandler

  @impl AbstractHandler
  def handle(action, %{model_name: "Region", attrs: attrs}) do
    IO.puts("!!! DomainModelHandler action: #{action}, Region, attrs: #{inspect(attrs)}")
    RegionHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: name, attrs: attrs}) do
    IO.puts("!!! DomainModelHandler action: #{action}, model: #{name}, attrs: #{inspect(attrs)}")
    :ok
  end
end
