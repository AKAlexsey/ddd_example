alias KalturaAdmin.Content.{TvStream}
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: TvStream do
  @permitted_attrs [:id, :stream_path, :status, :protocol, :encryption, :linear_channel_id]

  def get(%TvStream{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
