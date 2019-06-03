defmodule CtiKaltura.ProgramScheduling.ProgramRecordStatusMonitor do
  @moduledoc """
  Осуществляет отслеживание
  """

  @error_status "ERROR"

  alias CtiKaltura.Content
  alias CtiKaltura.ProgramScheduling.{SoapRequestResponseService, SoapRequests, Time}

  @doc """
  Выбирает все текущие записи или записи, программы которых уже завершены, но находящиеся в статусе
  отличном от COMPLETED и ERROR. И для каждой из них отправляет запрос, на сервер. В случае если значение :status
  на DVR сервере отличается от значения в базе, обновляет значение поля в базе.
  """
  @spec perform :: {:ok, atom} | {:ok, map()}
  def perform do
    case Content.current_program_records() do
      [] ->
        {:ok, :no_program_records}

      current_program_records ->
        responses =
          current_program_records
          |> Enum.map(&check_for_status_update/1)

        {success, errors} = SoapRequestResponseService.split_result(responses)

        {:ok,
         %{
           scheduling_time: Time.scheduling_time_label(NaiveDateTime.utc_now()),
           changed_program_records: success,
           errors: errors
         }}
    end
  end

  defp check_for_status_update(
         %{id: program_record_id, status: program_record_status} = program_record
       ) do
    with {:ok, %{recordingStatus: server_program_record_status}} <-
           SoapRequests.get_recording(program_record),
         false <- server_program_record_status == program_record_status do
      {:ok, %{id: ^program_record_id}} =
        Content.update_program_record(program_record, %{status: server_program_record_status})

      {:ok,
       "ProgramRecord id: #{program_record_id} changed status from #{
         inspect(program_record_status)
       } to #{inspect(server_program_record_status)}"}
    else
      true ->
        {:ok, "ProgramRecord id: #{program_record_id} status_does_not_changed"}

      {:error, %{faultstring: _} = reason} ->
        updated_program_record =
          Content.update_program_record(program_record, %{status: @error_status})

        {:error, {reason, updated_program_record}}

      {:error, reason} ->
        {:error, {reason, program_record}}
    end
  end
end
