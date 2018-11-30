alias KalturaAdmin.Content.ProgramRecord
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: ProgramRecord do
  @permitted_attrs [:id, :program_id, :codec, :status, :server_id]

  def get(%ProgramRecord{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
