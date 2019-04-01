alias CtiKaltura.Area.Subnet
alias CtiKaltura.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: Subnet do
  @permitted_attrs [:id, :region_id, :cidr, :name]

  def get(%Subnet{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
