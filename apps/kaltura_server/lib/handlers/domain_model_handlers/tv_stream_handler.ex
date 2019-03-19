defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false

  alias DomainModel.TvStream

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: TvStream

  def before_write(struct, raw_attrs) do
    struct
    |> put_complex_search_index(raw_attrs)
  end

  defp put_complex_search_index(%{protocol: protocol, status: status} = attrs, %{epg_id: epg_id}) do
    attrs
    |> Map.put(:complex_search_index, {epg_id, status, protocol})
  end
end
