alias CtiKaltura.Area.{Region, Subnet, RegionServerGroup}
alias CtiKaltura.Protocols.NotifyServerAttrs

alias CtiKaltura.Repo

import Ecto.Query

defimpl NotifyServerAttrs, for: Region do
  @permitted_attrs [:id, :name, :status]

  def get(%Region{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_subnet_ids(record)
    |> preload_server_group_ids(record)
  end

  defp preload_subnet_ids(attrs, %{subnets: subnets}) when is_list(subnets) do
    attrs
    |> Map.merge(%{subnet_ids: Enum.map(subnets, & &1.id)})
  end

  defp preload_subnet_ids(attrs, %{id: region_id}) do
    subnet_ids =
      from(sbn in Subnet, select: sbn.id, where: sbn.region_id == ^region_id)
      |> Repo.all()

    attrs
    |> Map.merge(%{subnet_ids: subnet_ids})
  end

  defp preload_server_group_ids(attrs, %{server_groups: server_groups})
       when is_list(server_groups) do
    attrs
    |> Map.merge(%{server_group_ids: Enum.map(server_groups, & &1.id)})
  end

  defp preload_server_group_ids(attrs, %{id: region_id}) do
    server_group_ids =
      from(
        rsg in RegionServerGroup,
        select: rsg.server_group_id,
        where: rsg.region_id == ^region_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{server_group_ids: server_group_ids})
  end
end
