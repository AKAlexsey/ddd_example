defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  alias DomainModel.Region

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Region,
    joined_attributes_and_models: [
      subnet_ids: "Subnet",
      server_group_ids: "ServerGroup"
    ]
end
