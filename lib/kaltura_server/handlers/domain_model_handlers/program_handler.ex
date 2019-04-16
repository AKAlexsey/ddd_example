defmodule CtiKaltura.DomainModelHandlers.ProgramHandler do
  @moduledoc false

  alias DomainModel.Program

  use CtiKaltura.DomainModelHandlers.AbstractHandler,
    table: Program,
    joined_attributes_and_models: [
      linear_channel_id: "LinearChannel",
      program_record_ids: "ProgramRecord"
    ],
    models_with_injected_attribute: [
      {:epg_id, "ProgramRecord", :program_record_ids}
    ]
end
