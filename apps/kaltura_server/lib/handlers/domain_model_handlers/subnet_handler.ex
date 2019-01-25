defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  alias DomainModel.Subnet

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Subnet,
    joined_attributes_and_models: [
      region_id: "Region"
    ]

  def before_write(%{cidr: cidr} = struct) do
    Map.put(struct, :parsed_cidr, CIDR.parse(cidr))
  end
end
