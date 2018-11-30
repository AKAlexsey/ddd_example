alias KalturaAdmin.Area.Region
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: Region do
  @permitted_attrs [:id, :name, :description, :status]

  def get(%Region{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
