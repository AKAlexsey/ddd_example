defmodule KalturaServer.DomainModelHandlers.ServerHandler do
  @moduledoc false

  alias DomainModel.Server

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: Server
end
