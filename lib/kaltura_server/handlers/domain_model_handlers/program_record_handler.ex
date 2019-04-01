defmodule CtiKaltura.DomainModelHandlers.ProgramRecordHandler do
  @moduledoc false

  alias DomainModel.ProgramRecord

  use CtiKaltura.DomainModelHandlers.AbstractHandler,
    table: ProgramRecord,
    joined_attributes_and_models: [
      program_id: "Program",
      server_id: "Server"
    ]

  def before_write(struct, raw_attrs) do
    struct
    |> put_complex_search_index(raw_attrs)
  end

  defp put_complex_search_index(
         struct,
         %{epg_id: epg_id, status: status, protocol: protocol} = _raw_attrs
       ) do
    struct
    |> Map.merge(%{
      complex_search_index: {epg_id, status, protocol}
    })
  end
end
