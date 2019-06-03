defmodule CtiKaltura.ProgramScheduling.ProgramsCleanerWorker do
  @moduledoc """
  Удаляет устаревшие Program, из базы и с DVR сервера.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :program_scheduling,
    configuration_alias: :programs_cleaner

  alias CtiKaltura.ProgramScheduling.ProgramScheduler

  def useful_job do
    case ProgramScheduler.clean_obsolete(storing_hours()) do
      {:ok, :no_programs} ->
        :ok

      {:ok, metadata} ->
        log_info(
          "Programs with ids #{inspect(metadata[:removed_ids])} before #{
            inspect(metadata[:cleaning_time])
          } has been removed"
        )

      {:error, reason} ->
        log_error("Error during cleaning Programs reason: #{inspect(reason)}")
    end

    :ok
  end

  # Configuration functions
  defp storing_hours, do: config()[:storing_hours]
end
