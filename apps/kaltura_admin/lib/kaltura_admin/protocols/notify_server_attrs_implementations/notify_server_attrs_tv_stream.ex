alias KalturaAdmin.Servers.ServerGroupsTvStream
alias KalturaAdmin.Content.{TvStream, Program}
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Repo

import Ecto.Query

defimpl NotifyServerAttrs, for: TvStream do
  @permitted_attrs [:id, :epg_id, :stream_path, :status, :name, :code_name]

  def get(%TvStream{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_server_group_ids(record)
    |> preload_program_ids(record)
  end

  defp preload_server_group_ids(attrs, %{server_groups: server_groups})
       when is_list(server_groups) do
    attrs
    |> Map.merge(%{server_group_ids: Enum.map(server_groups, & &1.id)})
  end

  defp preload_server_group_ids(attrs, %{id: tv_stream_id}) do
    server_group_ids =
      from(
        sgts in ServerGroupsTvStream,
        select: sgts.server_group_id,
        where: sgts.tv_stream_id == ^tv_stream_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{server_group_ids: server_group_ids})
  end

  defp preload_program_ids(attrs, %{programs: programs}) when is_list(programs) do
    attrs
    |> Map.merge(%{program_ids: Enum.map(programs, & &1.id)})
  end

  defp preload_program_ids(attrs, %{id: tv_stream_id}) do
    program_ids =
      from(
        p in Program,
        select: p.id,
        where: p.tv_stream_id == ^tv_stream_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{program_ids: program_ids})
  end
end
