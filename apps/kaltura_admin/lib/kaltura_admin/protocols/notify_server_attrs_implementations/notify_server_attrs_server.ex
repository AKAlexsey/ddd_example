alias KalturaAdmin.Servers.Server
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Servers.ServerGroupServer
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
    |> preload_subnet_ids(record)
  end

  defp preload_server_group_ids(attrs, %{server_groups: server_groups})
       when is_list(server_groups) do
    put_server_group_ids(attrs, get_ids(server_groups))
  end

  defp preload_server_group_ids(attrs, %{id: server_id}) do
    server_group_ids =
      from(
        sgs in ServerGroupServer,
        select: sgs.server_group_id,
        where: sgs.server_id == ^server_id
      )
      |> Repo.all()

    put_server_group_ids(attrs, server_group_ids)
  end

  defp put_server_group_ids(attrs, server_group_ids) do
    attrs
    |> Map.put(:server_group_ids, server_group_ids)
  end

  defp preload_program_record_ids(attrs, %{program_records: program_records})
       when is_list(program_records) do
    put_program_record_ids(attrs, get_ids(program_records))
  end

  defp preload_program_record_ids(attrs, %{id: server_id}) do
    program_record_ids =
      from(
        pr in ProgramRecord,
        select: pr.id,
        where: pr.server_id == ^server_id
      )
      |> Repo.all()

    put_program_record_ids(attrs, program_record_ids)
  end

  defp put_program_record_ids(attrs, program_record_ids) do
    Map.put(attrs, :program_record_ids, program_record_ids)
  end

  defp preload_subnet_ids(attrs, %{server_groups: %{regions: %{subnets: subnets}}} = record)
       when is_list(subnets) and length(subnets) > 0 do
    put_subnet_ids(attrs, record)
  end

  defp preload_subnet_ids(attrs, record) do
    record_with_preload = Repo.preload(record, server_groups: [regions: :subnets])
    put_subnet_ids(attrs, record_with_preload)
  end

  defp put_subnet_ids(attrs, %{server_groups: server_groups}) do
    subnet_ids =
      server_groups
      |> Enum.reduce([], fn %{regions: regions}, acc ->
        Enum.reduce(regions, acc, fn %{subnets: subnets}, acc1 -> acc1 ++ get_ids(subnets) end)
      end)
      |> Enum.uniq()

    Map.put(attrs, :subnet_ids, subnet_ids)
  end

  defp get_ids(collection) do
    Enum.map(collection, & &1.id)
  end
end
