defmodule CtiKaltura.ProgramScheduling.ProgramRecordScheduler do
  @moduledoc """
  Осуществляет планирование и удаление программ в БД и на DVR сервере.
  """

  @dvr_server_type "DVR"
  @server_active_status "ACTIVE"

  alias CtiKaltura.Content
  alias CtiKaltura.ProgramScheduling.{SoapRequestResponseService, SoapRequests, Time}

  @doc """
  Осуществляет создание записей в базе и планирование на DVR сервере с помошью отправки SOAP запросов.
  Принимает количество минут, за которое необходимо осуществлять планирование, возвращает tuple.
  """
  @spec perform(integer) :: {:ok, atom} | {:ok, map()} | {:error, any()}
  def perform(seconds_after_amount) do
    case Content.coming_soon_programs(
           NaiveDateTime.utc_now(),
           Time.seconds_after(seconds_after_amount)
         ) do
      [] ->
        {:ok, :no_programs}

      coming_soon_programs ->
        responses = Enum.flat_map(coming_soon_programs, &schedule_recordings/1)

        {success, errors} = SoapRequestResponseService.split_result(responses)

        {
          :ok,
          %{
            scheduling_time: Time.scheduling_time_label(NaiveDateTime.utc_now()),
            created_ids: Enum.map(success, & &1.id),
            errors: errors
          }
        }
    end
  end

  defp schedule_recordings(program) do
    program
    |> program_record_scheduling_params()
    |> Enum.map(&schedule_recording(&1))
  end

  defp program_record_scheduling_params(
         %{linear_channel: %{tv_streams: tv_streams} = linear_channel} = program
       ) do
    Enum.map(tv_streams, fn tv_stream -> {program, linear_channel, tv_stream} end)
  end

  defp schedule_recording({program, linear_channel, tv_stream} = params) do
    with {:ok, path} <- SoapRequests.schedule_recording(params),
         {:ok, program_record_params} <-
           get_program_record_params(path, program, linear_channel, tv_stream),
         {:ok, program_record} <- Content.create_program_record(program_record_params) do
      {:ok, program_record}
    else
      {:error, reason} ->
        {:error, {reason, params}}

      unexpected_error ->
        {:error, {unexpected_error, params}}
    end
  end

  defp get_program_record_params(path, %{id: program_id}, %{server_group: server_group}, %{
         protocol: protocol,
         encryption: encryption
       }) do
    case select_dvr_server(server_group) do
      {:ok, %{id: dvr_server_id}} ->
        {
          :ok,
          %{
            path: path,
            status: "NEW",
            protocol: protocol,
            encryption: encryption,
            program_id: program_id,
            server_id: dvr_server_id
          }
        }

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp select_dvr_server(%{servers: servers, name: name, id: server_group_id}) do
    case Enum.find(servers, fn %{type: type, status: status} ->
           type == @dvr_server_type and status == @server_active_status
         end) do
      nil ->
        {:error, "No active dvr server in ServerGroup #{name} with ID: #{server_group_id}"}

      dvr_server ->
        {:ok, dvr_server}
    end
  end

  @doc """
  Очищает устаревшие записи программ из базы данных и с DVR сервера.
  """
  @spec clean_obsolete(integer) :: :ok
  def clean_obsolete(storing_hours) do
    cleaning_time = Time.hours_ago(storing_hours)

    case Content.obsolete_program_records(cleaning_time) do
      [] ->
        {:ok, :no_program_records}

      obsolete_program_records ->
        Enum.each(obsolete_program_records, &Content.delete_program_record(&1))

        Enum.each(obsolete_program_records, &SoapRequests.remove_recording(&1))

        {:ok,
         %{
           cleaning_time: cleaning_time,
           removed_ids: Enum.map(obsolete_program_records, & &1.id)
         }}
    end
  end
end
