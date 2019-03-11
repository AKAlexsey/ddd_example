defmodule KalturaServer.DomainModelHandlers.LinearChannelHandler do
  @moduledoc false

  alias DomainModel.LinearChannel

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: LinearChannel
end
