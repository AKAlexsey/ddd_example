defmodule CtiKaltura.ProgramScheduling.ProgramScheduler do
  @moduledoc """
  Осуществляет планирование программы передач, по данным из EPG файла.
  """

  @kaltura_date_format_regex ~r/(\d{4,4})(\d{2,2})(\d{2,2})(\d{2,2})(\d{2,2})(\d{2,2})/

  alias CtiKaltura.Content

  @doc """
  По данным из EPG файла осущетсвляет инициализацию ProgramRecord для созданного в базе канала.
  Если канала с заданным EPG не существует, возаращет соответствующую ошибку.
  """
  @spec perform(map()) :: :ok | {:error, :linear_channel_does_not_exist}
  def perform(%{linear_channel: %{epg_id: epg_id}, programs: programs}) do
    case Content.get_linear_channel_by_epg(epg_id) do
      %{id: linear_channel_id} ->
        create_programs(programs, linear_channel_id)
        :ok

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

    start_datetime = time_to_utc(first_program.start_datetime)
    end_datetime = time_to_utc(last_program.end_datetime)

    Content.delete_programs_from_interval(start_datetime, end_datetime, linear_channel_id)
  end

  defp create_new_programs(programs_list, linear_channel_id) do
    programs_list
    |> Enum.each(fn program_params ->
      program_params
      |> Map.put(:linear_channel_id, linear_channel_id)
      |> Map.update!(:start_datetime, &time_to_utc/1)
      |> Map.update!(:end_datetime, &time_to_utc/1)
      |> Content.create_program()
    end)
  end

  @doc """
  Преобразует время формата "20190401001200" в NaiveDateTime UTC.
  """
  @spec time_to_utc(binary) :: NaiveDateTime.t()
  def time_to_utc(time_string) do
    [_full, year, month, day, hours, minutes, seconds] =
      Regex.run(@kaltura_date_format_regex, time_string)

    {:ok, datetime} =
      NaiveDateTime.from_erl(
        {{string_to_integer(year), string_to_integer(month), string_to_integer(day)},
         {string_to_integer(hours), string_to_integer(minutes), string_to_integer(seconds)}}
      )

    datetime
  end

  defp string_to_integer(str) do
    {integer, ""} = Integer.parse(str)
    integer
  end
end
