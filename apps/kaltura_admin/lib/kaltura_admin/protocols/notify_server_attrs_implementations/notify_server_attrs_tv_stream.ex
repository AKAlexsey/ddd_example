alias KalturaAdmin.Content.TvStream
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: TvStream do
  @permitted_attrs [:id, :epg_id, :stream_path, :status, :name, :code_name]

  def get(%TvStream{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
