defmodule CtiKaltura.ProgramScheduling.ProgramRecordsStatusWorker do
  @moduledoc """
  Осуществляет актуализацию состояния ProgramRecord с помошью отправки SOAP запросов на DVR сервер.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :program_scheduling,
    configuration_alias: :program_records_status

  alias CtiKaltura.ProgramScheduling.ProgramRecordStatusMonitor

  def useful_job do
    case ProgramRecordStatusMonitor.perform() do
      {:ok, :no_program_records} ->
        :ok

      {:ok, metadata} ->
        log_info(
          "SchedulingTime #{inspect(metadata[:scheduling_time])}.\nProgramRecords statuses has been changed changed_program_records: #{
            inspect(metadata[:changed_program_records])
          }\nErrors #{inspect(metadata[:errors])}"
        )
    end

    :ok
  end
end
