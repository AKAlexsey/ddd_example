defmodule KalturaServer.DomainModelHandlers.LinearChannelHandler do
  @moduledoc false

  alias DomainModel.LinearChannel

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: LinearChannel,
    joined_attributes_and_models: [
      server_group_id: "ServerGroup",
      program_ids: "Program",
      tv_stream_ids: "TvStream"
    ]
end
