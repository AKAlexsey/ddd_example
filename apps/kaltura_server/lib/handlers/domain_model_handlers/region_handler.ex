defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  alias DomainModel.Region
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  @enum_fields [:status]
  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Region,
    joined_attributes_and_models: [
      subnet_ids: ["Subnet", notify_always: true],
      server_group_ids: "ServerGroup"
    ]

  def before_write(struct, _raw_attrs) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
  end
end
