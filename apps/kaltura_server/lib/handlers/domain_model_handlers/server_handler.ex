defmodule KalturaServer.DomainModelHandlers.ServerHandler do
  @moduledoc false

  alias DomainModel.Server
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  @enum_fields [:type, :status]
  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Server,
    joined_attributes_and_models: [
      server_group_ids: "ServerGroup",
      program_record_ids: "ProgramRecord",
      subnet_ids: ["Subnet", notify_always: true]
    ]

  def before_write(struct, _raw_attrs) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
  end
end
