defmodule CtiKaltura.ProgramScheduling.ParseFileStage do
  @moduledoc """
  GenStage. Скачивает EPG файл, парсит, берёт из него данные по LinearChannel и Program,
  затем отправляет в следующий Stage.
  """

  use GenStage

  alias CtiKaltura.ProgramScheduling.EpgFileParser

  def(start_link(_)) do
    GenStage.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__))
  end

  def init(:ok) do
    schedule_periodical_job(scanning_interval())
    {:producer, nil}
  end

  defp schedule_periodical_job(interval) do
    if file_parsing_enabled?() do
      Process.send_after(self(), :get_one_file, interval)
    end
  end

  defp via_tuple(name), do: {:via, :global, name}

  def handle_info(:get_one_file, _state) do
    scan_directory_time = NaiveDateTime.utc_now()

    files_directory()
    |> EpgFileParser.one_file_data(processed_files_directory())
    |> case do
      {:ok, :no_file} ->
        schedule_periodical_job(scanning_interval())
        {:noreply, [], scan_directory_time}

      {:ok, %{linear_channel: linear_channel, programs: programs_list}} ->
        schedule_periodical_job(processing_interval())

        {:noreply, [%{linear_channel: linear_channel, programs: programs_list}],
         scan_directory_time}

      {:error, _reason} ->
        # Код, обрабатывающий ситуацию, когда файл невалиден
        schedule_periodical_job(scanning_interval())
        {:noreply, [], scan_directory_time}
    end
  end

  def handle_demand(_, state), do: {:noreply, [], state}

  # Configuration functions
  defp config do
    Application.get_env(:cti_kaltura, :epg_file_parser)
  end

  defp scanning_interval do
    config()[:scan_file_directory_interval]
  end

  defp file_parsing_enabled? do
    config()[:enabled]
  end

  defp processing_interval do
    config()[:process_file_interval]
  end

  defp files_directory do
    config()[:files_directory]
  end

  defp processed_files_directory do
    config()[:processed_files_directory] || "#{config()[:files_directory]}/processed"
  end
end
