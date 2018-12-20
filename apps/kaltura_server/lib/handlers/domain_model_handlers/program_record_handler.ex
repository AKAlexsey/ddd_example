defmodule KalturaServer.DomainModelHandlers.ProgramRecordHandler do
  @moduledoc false

  alias DomainModel.ProgramRecord

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: ProgramRecord,
    joined_attributes_and_models: [
      program_id: "Program",
      server_id: "Server"
    ]
end
