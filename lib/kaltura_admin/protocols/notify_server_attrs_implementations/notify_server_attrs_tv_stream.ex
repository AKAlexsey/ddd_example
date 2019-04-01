alias CtiKaltura.Content.{TvStream}
alias CtiKaltura.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: TvStream do
  @permitted_attrs [:id, :stream_path, :status, :protocol, :encryption, :linear_channel_id]

  alias CtiKaltura.Repo
  alias CtiKaltura.Content.LinearChannel

  def get(%TvStream{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> put_linear_channel_epg_id(record)
  end

  def put_linear_channel_epg_id(attrs, %{linear_channel: %{epg_id: epg_id}} = _record) do
    Map.put(attrs, :epg_id, epg_id)
  end

  def put_linear_channel_epg_id(%{linear_channel_id: linear_channel_id} = attrs, _record) do
    %{epg_id: epg_id} = Repo.get(LinearChannel, linear_channel_id)
    Map.put(attrs, :epg_id, epg_id)
  end
end
