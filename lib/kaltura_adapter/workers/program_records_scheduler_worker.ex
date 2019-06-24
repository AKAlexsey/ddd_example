defmodule CtiKaltura.ProgramScheduling.ProgramRecordsSchedulerWorker do
  @moduledoc """
  Осуществляет планирование ProgramRecord, с помошью отправки SOAP запросов на DVR сервер.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :program_scheduling,
    configuration_alias: :program_records_scheduler

  alias CtiKaltura.ProgramScheduling.ProgramRecordScheduler

  def useful_job do
    case ProgramRecordScheduler.perform(seconds_after()) do
      {:ok, :no_programs} ->
        :ok

      {:ok, metadata} ->
        log_info(
          "SchedulingTime #{inspect(metadata[:scheduling_time])}.\nProgramRecords with ids #{
            inspect(metadata[:created_ids])
          } has been created.\nErrors: #{inspect(metadata[:errors])}"
        )

      {:error, reason} ->
        log_error("Error during scheduling #{inspect(reason)}")
    end

    :ok
  end

  defp seconds_after, do: config()[:seconds_after]
end
