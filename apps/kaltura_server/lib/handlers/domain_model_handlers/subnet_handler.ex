defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  alias DomainModel.Subnet
  import DomainModel, only: [cidr_fields_for_search: 1]

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Subnet,
    joined_attributes_and_models: [
      region_id: "Region"
    ]

  def before_write(%{cidr: cidr} = struct, _raw_attrs) do
    Map.merge(struct, cidr_fields_for_search(cidr))
  end
end
