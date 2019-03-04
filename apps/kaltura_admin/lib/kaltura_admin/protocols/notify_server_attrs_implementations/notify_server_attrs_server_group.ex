alias KalturaAdmin.Servers.ServerGroup
alias KalturaAdmin.Protocols.NotifyServerAttrs

alias KalturaAdmin.Repo
alias KalturaAdmin.Servers.ServerGroupServer
alias KalturaAdmin.Content.LinearChannel
alias KalturaAdmin.Area.RegionServerGroup

import Ecto.Query

defimpl NotifyServerAttrs, for: ServerGroup do
  @permitted_attrs [:id, :name, :status]

  def get(%ServerGroup{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_server_ids(record)
    |> preload_region_ids(record)
    |> preload_linear_channel_ids(record)
    |> preload_subnet_ids(record)
  end

  defp preload_server_ids(attrs, %{servers: servers}) when is_list(servers) do
    put_server_ids(attrs, get_ids(servers))
  end

  defp preload_server_ids(attrs, %{id: server_group_id}) do
    server_ids =
      from(
        sgs in ServerGroupServer,
        select: sgs.server_id,
        where: sgs.server_group_id == ^server_group_id
      )
      |> Repo.all()

    put_server_ids(attrs, server_ids)
  end

  defp put_server_ids(attrs, server_ids) do
    attrs
    |> Map.merge(%{server_ids: server_ids})
  end

  defp preload_region_ids(attrs, %{regions: regions}) when is_list(regions) do
    put_region_ids(attrs, get_ids(regions))
  end

  defp preload_region_ids(attrs, %{id: server_group_id}) do
    region_ids =
      from(
        rsg in RegionServerGroup,
        select: rsg.region_id,
        where: rsg.server_group_id == ^server_group_id
      )
      |> Repo.all()

    put_region_ids(attrs, region_ids)
  end

  defp put_region_ids(attrs, region_ids) do
    attrs
    |> Map.merge(%{region_ids: region_ids})
  end

  defp preload_linear_channel_ids(attrs, %{linear_channels: linear_channels})
       when is_list(linear_channels) do
    put_linear_channel_ids(attrs, get_ids(linear_channels))
  end

  defp preload_linear_channel_ids(attrs, %{id: server_group_id}) do
    linear_channel_ids =
      from(
        lc in LinearChannel,
        select: lc.id,
        where: lc.server_group_id == ^server_group_id
      )
      |> Repo.all()

    put_linear_channel_ids(attrs, linear_channel_ids)
  end

  defp put_linear_channel_ids(attrs, linear_channel_ids) do
    attrs
    |> Map.merge(%{linear_channel_ids: linear_channel_ids})
  end

  defp preload_subnet_ids(attrs, %{regions: regions} = record)
       when is_list(regions) and length(regions) > 0 do
    put_subnet_ids(attrs, record)
  end

  defp preload_subnet_ids(attrs, record) do
    record_with_preload = Repo.preload(record, regions: :subnets)
    put_subnet_ids(attrs, record_with_preload)
  end

  defp put_subnet_ids(attrs, %{regions: regions}) do
    subnet_ids =
      regions
      |> Enum.reduce([], fn %{subnets: subnets}, acc -> acc ++ get_ids(subnets) end)
      |> Enum.uniq()

    Map.put(attrs, :subnet_ids, subnet_ids)
  end

  defp get_ids(collection) do
    Enum.map(collection, & &1.id)
  end
end
