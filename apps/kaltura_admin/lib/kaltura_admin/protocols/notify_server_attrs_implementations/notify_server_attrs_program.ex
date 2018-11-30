alias KalturaAdmin.Content.Program
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: Program do
  @permitted_attrs [:id, :name, :tv_stream_id, :epg_id]

  def get(%Program{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
