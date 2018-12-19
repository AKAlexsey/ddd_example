defmodule KalturaServer.DomainModelHandlers.ProgramHandler do
  @moduledoc false

  alias DomainModel.Program

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: Program,
    joined_attributes_and_models: [
      tv_stream_id: "TvStream",
      program_record_ids: "ProgramRecord"
    ]
end
