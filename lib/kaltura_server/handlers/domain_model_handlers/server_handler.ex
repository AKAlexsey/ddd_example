defmodule CtiKaltura.DomainModelHandlers.ServerHandler do
  @moduledoc false

  alias DomainModel.Server

  use CtiKaltura.DomainModelHandlers.AbstractHandler,
    table: Server,
    joined_attributes_and_models: [
      server_group_ids: "ServerGroup",
      program_record_ids: "ProgramRecord"
    ],
    models_with_injected_attribute: [
      {:prefix, "ProgramRecord", :program_record_ids}
    ]
end
