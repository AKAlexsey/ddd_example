defmodule CtiKaltura.ProgramScheduling.ParseFileWorker do
  @moduledoc """
  GenServer. Скачивает EPG файл, парсит, берёт из него данные по LinearChannel и Program,
  затем отправляет в CreateProgramsWorker.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :epg_files,
    configuration_alias: :epg_file_parser

  alias CtiKaltura.ProgramScheduling.{CreateProgramsWorker, EpgFileParser}

  def useful_job do
    files_directory()
    |> EpgFileParser.one_file_data(processed_files_directory())
    |> case do
      {:ok, :no_file} ->
        :ok

      {:ok, %{linear_channel: linear_channel, programs: programs_list}} ->
        log_info(
          "Start scheduling programs for LinearChannel #{inspect(linear_channel)}.\nPrograms ids: #{
            inspect(Enum.map(programs_list, & &1.epg_id))
          }"
        )

        CreateProgramsWorker.send_program_schedule_data(%{
          linear_channel: linear_channel,
          programs: programs_list
        })

        :ok

      {:error, reason} ->
        log_info("Error during processing file reason: #{inspect(reason)}")
        :ok
    end
  end

  # Configuration functions
  defp files_directory, do: config()[:files_directory]

  defp processed_files_directory do
    config()[:processed_files_directory] || "#{config()[:files_directory]}/processed"
  end
end
