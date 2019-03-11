defmodule KalturaServer.DomainModelHandlers.ProgramRecordHandler do
  @moduledoc false

  alias DomainModel.ProgramRecord
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  @enum_fields [:status, :protocol]
  use KalturaServer.DomainModelHandlers.AbstractHandler, table: ProgramRecord

  def before_write(struct, raw_attrs) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
    |> put_complex_search_index(raw_attrs)
  end

  defp put_complex_search_index(
         struct,
         %{epg_id: epg_id, status: status, protocol: protocol} = _raw_attrs
       ) do
    struct
    |> Map.merge(%{
      complex_search_index: {epg_id, normalize_enum(status), normalize_enum(protocol)}
    })
  end
end
