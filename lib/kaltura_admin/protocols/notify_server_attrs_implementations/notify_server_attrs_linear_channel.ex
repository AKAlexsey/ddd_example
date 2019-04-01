alias CtiKaltura.Content.{LinearChannel, Program, TvStream}
alias CtiKaltura.Protocols.NotifyServerAttrs
alias CtiKaltura.Repo

import Ecto.Query

defimpl NotifyServerAttrs, for: LinearChannel do
  @permitted_attrs [:id, :epg_id, :name, :code_name, :server_group_id]

  def get(%LinearChannel{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_program_ids(record)
    |> preload_tv_stream_ids(record)
  end

  defp preload_tv_stream_ids(attrs, %{tv_streams: tv_streams}) when is_list(tv_streams) do
    attrs
    |> Map.merge(%{tv_stream_ids: Enum.map(tv_streams, & &1.id)})
  end

  defp preload_tv_stream_ids(attrs, %{id: linear_channel_id}) do
    tv_stream_ids =
      from(
        p in TvStream,
        select: p.id,
        where: p.linear_channel_id == ^linear_channel_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{tv_stream_ids: tv_stream_ids})
  end

  defp preload_program_ids(attrs, %{programs: programs}) when is_list(programs) do
    attrs
    |> Map.merge(%{program_ids: Enum.map(programs, & &1.id)})
  end

  defp preload_program_ids(attrs, %{id: linear_channel_id}) do
    program_ids =
      from(
        p in Program,
        select: p.id,
        where: p.linear_channel_id == ^linear_channel_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{program_ids: program_ids})
  end
end
