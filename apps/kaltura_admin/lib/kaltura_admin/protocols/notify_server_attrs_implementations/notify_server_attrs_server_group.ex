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
  end

  defp preload_server_ids(attrs, %{servers: servers}) when is_list(servers) do
    attrs
    |> Map.merge(%{server_ids: Enum.map(servers, & &1.id)})
  end

  defp preload_server_ids(attrs, %{id: server_group_id}) do
    server_ids =
      from(
        sgs in ServerGroupServer,
        select: sgs.server_id,
        where: sgs.server_group_id == ^server_group_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{server_ids: server_ids})
  end

  defp preload_region_ids(attrs, %{regions: regions}) when is_list(regions) do
    attrs
    |> Map.merge(%{server_ids: Enum.map(regions, & &1.id)})
  end

  defp preload_region_ids(attrs, %{id: server_group_id}) do
    region_ids =
      from(
        rsg in RegionServerGroup,
        select: rsg.region_id,
        where: rsg.server_group_id == ^server_group_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{region_ids: region_ids})
  end

  defp preload_linear_channel_ids(attrs, %{linear_channels: linear_channels})
       when is_list(linear_channels) do
    attrs
    |> Map.merge(%{linear_channel_ids: Enum.map(linear_channels, & &1.id)})
  end

  defp preload_linear_channel_ids(attrs, %{id: server_group_id}) do
    linear_channel_ids =
      from(
        lc in LinearChannel,
        select: lc.id,
        where: lc.server_group_id == ^server_group_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{linear_channel_ids: linear_channel_ids})
  end
end
