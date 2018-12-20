defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false

  alias DomainModel.TvStream

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: TvStream,
    joined_attributes_and_models: [
      server_group_ids: "ServerGroup",
      program_ids: "Program"
    ]
end
