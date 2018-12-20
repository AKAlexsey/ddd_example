defmodule KalturaServer.Handlers.DomainModelHandler do
  @moduledoc """
  Handle notifications after Create Update Delete Refresh RefreshByRequest events with database.
  """
  alias KalturaServer.Handlers.AbstractHandler

  alias KalturaServer.DomainModelHandlers.{
    ProgramHandler,
    ProgramRecordHandler,
    RegionHandler,
    ServerGroupHandler,
    ServerHandler,
    SubnetHandler,
    TvStreamHandler
  }

  @behaviour AbstractHandler

  def handle(action, %{model_name: "Program", attrs: attrs}) do
    ProgramHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "ProgramRecord", attrs: attrs}) do
    ProgramRecordHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "Region", attrs: attrs}) do
    RegionHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "ServerGroup", attrs: attrs}) do
    ServerGroupHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "Server", attrs: attrs}) do
    ServerHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "Subnet", attrs: attrs}) do
    SubnetHandler.handle(action, attrs)
    :ok
  end

  def handle(action, %{model_name: "TvStream", attrs: attrs}) do
    TvStreamHandler.handle(action, attrs)
    :ok
  end

  def handle(event, %{model_name: name, attrs: attrs}) do
    raise "KalturaServer.Handlers.DomainModelHandler unknown model name #{inspect(name)} event: #{
            event
          } attrs #{inspect(attrs)}"

    :ok
  end
end
