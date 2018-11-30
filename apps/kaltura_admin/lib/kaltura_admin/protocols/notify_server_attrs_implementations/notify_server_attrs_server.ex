alias KalturaAdmin.Servers.Server
alias KalturaAdmin.Protocols.NotifyServerAttrs

defimpl NotifyServerAttrs, for: Server do
  @permitted_attrs [
    :id,
    :type,
    :domain_name,
    :ip,
    :port,
    :status,
    :weight,
    :prefix,
    :healthcheck_enabled
  ]

  def get(%Server{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
  end
end
