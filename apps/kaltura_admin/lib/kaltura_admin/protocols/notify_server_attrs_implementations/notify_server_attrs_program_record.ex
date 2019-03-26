alias KalturaAdmin.Content.{Program, ProgramRecord}
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Servers.Server
alias KalturaAdmin.Repo

defimpl NotifyServerAttrs, for: ProgramRecord do
  @permitted_attrs [:id, :program_id, :server_id, :status, :protocol, :encryption, :path]

  def get(%ProgramRecord{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_server_prefix(record)
    |> preload_program_epg(record)
  end

  defp preload_server_prefix(attrs, %{server: %{prefix: prefix}}) do
    attrs
    |> Map.put(:prefix, prefix)
  end

  defp preload_server_prefix(attrs, %{server_id: server_id}) do
    %{prefix: prefix} = Repo.get(Server, server_id)

    attrs
    |> Map.put(:prefix, prefix)
  end

  defp preload_program_epg(attrs, %{program: %{epg_id: epg_id}}) do
    attrs
    |> Map.put(:epg_id, epg_id)
  end

  defp preload_program_epg(attrs, %{program_id: program_id}) do
    %{epg_id: epg_id} = Repo.get(Program, program_id)

    attrs
    |> Map.put(:epg_id, epg_id)
  end
end
