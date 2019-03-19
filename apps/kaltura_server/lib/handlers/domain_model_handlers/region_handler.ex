defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  alias DomainModel.Region

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: Region
end
