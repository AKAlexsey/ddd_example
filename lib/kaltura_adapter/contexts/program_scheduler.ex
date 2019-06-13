defmodule CtiKaltura.ProgramScheduling.ProgramScheduler do
  @moduledoc """
  Содержит функции планирования программы передач, по данным из EPG файла. И функцию удаления.

  """

  alias CtiKaltura.Content
  alias CtiKaltura.ProgramScheduling.Time

  @doc """
  По данным из EPG файла осущетсвляет инициализацию ProgramRecord для созданного в базе канала.
  Если канала с заданным EPG не существует, возаращет соответствующую ошибку.
  """
  @spec perform(map()) ::
          :ok
          | {:error, :linear_channel_does_not_exist}
          | {:error, :linear_channel_dvr_does_not_enabled}
  def perform(%{linear_channel: %{epg_id: epg_id}, programs: programs}) do
    case Content.get_linear_channel_by_epg(epg_id) do
      %{id: linear_channel_id, dvr_enabled: true} ->
        create_programs(programs, linear_channel_id)
        :ok

      %{dvr_enabled: false} ->
        {:error, :linear_channel_dvr_does_not_enabled}

      nil ->
        {:error, :linear_channel_does_not_exist}
    end
  end

  defp create_programs([], _linear_channel_id) do
    :ok
  end

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

  defp create_new_programs(programs_list, linear_channel_id) do
    programs_list
    |> Enum.each(fn program_params ->
      program_params
      |> Map.put(:linear_channel_id, linear_channel_id)
      |> Map.update!(:start_datetime, &Time.time_to_utc/1)
      |> Map.update!(:end_datetime, &Time.time_to_utc/1)
      |> Content.create_program()
    end)
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
