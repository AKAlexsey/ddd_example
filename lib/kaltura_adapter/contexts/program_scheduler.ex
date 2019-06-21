defmodule CtiKaltura.ProgramScheduling.ProgramScheduler do
  @moduledoc """
  Содержит функции планирования программы передач, по данным из EPG файла. И функцию удаления.

  """

  alias CtiKaltura.Content
  alias CtiKaltura.ProgramScheduling.Time

  @doc """
  По данным из EPG файла осущетсвляет инициализацию ProgramRecord для созданного в базе канала.
  Если канала с заданным EPG не существует, возаращет соответствующую ошибку.

  Второй аргумент добавлен в целях тестирования и для "Чистоты" функции.
  """
  @spec perform(map(), integer, NaiveDateTime.t()) ::
          :ok
          | {:error, :linear_channel_does_not_exist}
          | {:error, :linear_channel_dvr_does_not_enabled}
  def perform(program_params, threshold_seconds, time \\ nil)

  def perform(program_params, threshold_seconds, nil) do
    perform(program_params, threshold_seconds, NaiveDateTime.utc_now())
  end

  def perform(
        %{linear_channel: %{epg_id: epg_id}, programs: programs},
        threshold_seconds,
        current_time
      ) do
    case Content.get_linear_channel_by_epg(epg_id) do
      %{id: linear_channel_id, dvr_enabled: true} ->
        programs
        |> filter_appropriate_programs(threshold_seconds, current_time)
        |> create_programs(linear_channel_id)

      %{dvr_enabled: false} ->
        {:error, :linear_channel_dvr_does_not_enabled}

      nil ->
        {:error, :linear_channel_does_not_exist}
    end
  end

  defp filter_appropriate_programs(programs, threshold_seconds, current_time) do
    threshold_time = NaiveDateTime.add(current_time, threshold_seconds)

    programs
    |> Enum.filter(fn %{start_datetime: start_datetime} ->
      NaiveDateTime.diff(Time.time_to_utc(start_datetime), threshold_time) > 0
    end)
  end

  defp create_programs([], _), do: :ok

  defp create_programs(programs_list, linear_channel_id) do
    delete_old_programs(programs_list, linear_channel_id)
    create_new_programs(programs_list, linear_channel_id)
  end

  defp delete_old_programs(programs_list, linear_channel_id) do
    first_program = Enum.at(programs_list, 0)
    last_program = Enum.at(programs_list, -1)

    start_datetime = Time.time_to_utc(first_program.start_datetime)
    end_datetime = Time.time_to_utc(last_program.end_datetime)

    Content.delete_programs_from_interval(start_datetime, end_datetime, linear_channel_id)
  end

  defp create_new_programs(filtered_programs_list, linear_channel_id) do
    filtered_programs_list
    |> Enum.each(fn program_params ->
      program_params
      |> Map.put(:linear_channel_id, linear_channel_id)
      |> Map.update!(:start_datetime, &Time.time_to_utc/1)
      |> Map.update!(:end_datetime, &Time.time_to_utc/1)
      |> Content.create_program()
    end)

    {:ok, %{programs: filtered_programs_list, linear_channel: linear_channel_id}}
  end

  @doc """
  Удаляет устаревшие программы из базы данных.
  """
  @spec clean_obsolete(integer) :: :ok
  def clean_obsolete(storing_hours) do
    cleaning_time = Time.hours_ago(storing_hours)

    case Content.obsolete_programs(cleaning_time) do
      [] ->
        {:ok, :no_programs}

      obsolete_programs ->
        Enum.each(obsolete_programs, &Content.delete_program(&1))

        {:ok,
         %{
           cleaning_time: cleaning_time,
           removed_ids: Enum.map(obsolete_programs, & &1.id)
         }}
    end
  end
end
