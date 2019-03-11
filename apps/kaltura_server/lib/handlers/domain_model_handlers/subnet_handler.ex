defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  alias DomainModel.Subnet
  import DomainModel, only: [cidr_fields_for_search: 1]

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: Subnet

  def before_write(%{cidr: cidr} = struct, _raw_attrs) do
    Map.merge(struct, cidr_fields_for_search(cidr))
  end
end
