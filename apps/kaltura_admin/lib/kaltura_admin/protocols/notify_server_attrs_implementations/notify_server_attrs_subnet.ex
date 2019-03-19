alias KalturaAdmin.Area.Subnet
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Repo

defimpl NotifyServerAttrs, for: Subnet do
  @permitted_attrs [:id, :region_id, :cidr, :name]

  def get(%Subnet{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_server_ids(record)
  end

  defp preload_server_ids(attrs, %{region: %{server_groups: server_groups}} = record)
       when is_list(server_groups) do
    put_server_ids(attrs, record)
  end

  defp preload_server_ids(attrs, record) do
    record_with_preloads =
      record
      |> Repo.preload(region: [server_groups: :servers])

    put_server_ids(attrs, record_with_preloads)
  end

  defp put_server_ids(attrs, %{region: %{status: "ACTIVE", server_groups: server_groups}}) do
    server_ids =
      server_groups
      |> Enum.map(fn
        %{status: "ACTIVE", servers: servers} ->
          Enum.map(servers, & &1.id)

        _ ->
          []
      end)
      |> List.flatten()
      |> Enum.uniq()

    attrs
    |> Map.merge(%{server_ids: server_ids})
  end

  defp put_server_ids(attrs, _record) do
    Map.merge(attrs, %{server_ids: []})
  end
end
