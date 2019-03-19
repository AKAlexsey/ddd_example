defmodule KalturaServer.DomainModelHandlers.ServerGroupHandler do
  @moduledoc false

  alias DomainModel.ServerGroup

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: ServerGroup
end
