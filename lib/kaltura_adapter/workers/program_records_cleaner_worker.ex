defmodule CtiKaltura.ProgramScheduling.ProgramRecordsCleanerWorker do
  @moduledoc """
  Удаляет устаревшие ProgramRecord, из базы и с DVR сервера.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :program_scheduling,
    configuration_alias: :program_records_cleaner

  alias CtiKaltura.ProgramScheduling.ProgramRecordScheduler

  def useful_job do
    case ProgramRecordScheduler.clean_obsolete(storing_hours()) do
      {:ok, :no_program_records} ->
        :ok

      {:ok, metadata} ->
        log_info(
          "ProgramRecords with ids #{inspect(metadata[:removed_ids])} before #{
            inspect(metadata[:cleaning_time])
          } has been removed"
        )

      {:error, reason} ->
        log_error("Error during cleaning ProgramRecords reason: #{inspect(reason)}")
    end

    :ok
  end

  # Configuration functions
  defp storing_hours, do: config()[:storing_hours]
end
