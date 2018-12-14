alias KalturaAdmin.Servers.ServerGroup
alias KalturaAdmin.Protocols.NotifyServerAttrs

alias KalturaAdmin.Repo
alias KalturaAdmin.Servers.ServerGroupServer

import Ecto.Query

defimpl NotifyServerAttrs, for: ServerGroup do
  @permitted_attrs [:id, :name, :status]

  def get(%ServerGroup{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_server_ids(record)
  end

  defp preload_server_ids(attrs, %{servers: servers}) when is_list(servers) do
    attrs
    |> Map.merge(%{server_ids: Enum.map(servers, & &1.id)})
  end

  defp preload_server_ids(attrs, %{id: server_group_id}) do
    server_ids =
      from(
        sgs in ServerGroupServer,
        select: sgs.id,
        where: sgs.server_group_id == ^server_group_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{server_ids: server_ids})
  end
end
