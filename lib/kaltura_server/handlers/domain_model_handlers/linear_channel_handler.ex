defmodule CtiKaltura.DomainModelHandlers.LinearChannelHandler do
  @moduledoc false

  alias DomainModel.LinearChannel

  use CtiKaltura.DomainModelHandlers.AbstractHandler,
    table: LinearChannel,
    joined_attributes_and_models: [
      server_group_id: "ServerGroup",
      program_ids: "Program",
      tv_stream_ids: "TvStream"
    ],
    models_with_injected_attribute: [
      {:epg_id, "TvStream", :tv_stream_ids}
    ]
end
