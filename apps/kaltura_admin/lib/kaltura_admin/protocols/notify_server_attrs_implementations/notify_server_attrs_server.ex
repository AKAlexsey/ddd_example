alias KalturaAdmin.Servers.Server
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Servers.{ServerGroupServer}
alias KalturaAdmin.Content.ProgramRecord
alias KalturaAdmin.Repo

import Ecto.Query

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
    |> preload_server_group_ids(record)
    |> preload_program_record_ids(record)
  end

  defp preload_server_group_ids(attrs, %{server_groups: server_groups})
       when is_list(server_groups) do
    attrs
    |> Map.merge(%{server_group_ids: Enum.map(server_groups, & &1.id)})
  end

  defp preload_server_group_ids(attrs, %{id: server_id}) do
    server_group_ids =
      from(
        sgs in ServerGroupServer,
        select: sgs.server_group_id,
        where: sgs.server_id == ^server_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{server_group_ids: server_group_ids})
  end

  defp preload_program_record_ids(attrs, %{program_records: program_records})
       when is_list(program_records) do
    attrs
    |> Map.merge(%{program_record_ids: Enum.map(program_records, & &1.id)})
  end

  defp preload_program_record_ids(attrs, %{id: server_id}) do
    program_record_ids =
      from(
        pr in ProgramRecord,
        select: pr.id,
        where: pr.server_id == ^server_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{program_record_ids: program_record_ids})
  end
end
