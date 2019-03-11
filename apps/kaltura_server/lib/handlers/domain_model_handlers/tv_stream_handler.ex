defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false
  @enum_fields [:status, :protocol, :encryption]

  alias DomainModel.TvStream
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: TvStream

  def before_write(struct, raw_attrs) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
    |> put_complex_search_index(raw_attrs)
  end

  defp put_complex_search_index(%{protocol: protocol, status: status} = attrs, %{epg_id: epg_id}) do
    attrs
    |> Map.put(:complex_search_index, {epg_id, status, protocol})
  end
end
