defmodule KalturaServer.DomainModelHandlers.ServerHandler do
  @moduledoc false

  alias DomainModel.Server

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Server,
    joined_attributes_and_models: [
      server_group_ids: "ServerGroup",
      program_record_ids: "ProgramRecord"
    ]
end
