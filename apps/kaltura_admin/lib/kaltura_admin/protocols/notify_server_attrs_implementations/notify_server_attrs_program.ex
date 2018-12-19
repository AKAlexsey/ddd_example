alias KalturaAdmin.Content.{Program, ProgramRecord}
alias KalturaAdmin.Protocols.NotifyServerAttrs
alias KalturaAdmin.Repo

import Ecto.Query

defimpl NotifyServerAttrs, for: Program do
  @permitted_attrs [:id, :name, :tv_stream_id, :epg_id]

  def get(%Program{} = record) do
    record
    |> Map.from_struct()
    |> Map.split(@permitted_attrs)
    |> (fn {permitted, _filtered} -> permitted end).()
    |> preload_program_record_ids(record)
  end

  defp preload_program_record_ids(attrs, %{program_records: program_records})
       when is_list(program_records) do
    attrs
    |> Map.merge(%{program_record_ids: Enum.map(program_records, & &1.id)})
  end

  defp preload_program_record_ids(attrs, %{id: program_id}) do
    program_record_ids =
      from(
        prr in ProgramRecord,
        select: prr.id,
        where: prr.program_id == ^program_id
      )
      |> Repo.all()

    attrs
    |> Map.merge(%{program_record_ids: program_record_ids})
  end
end
