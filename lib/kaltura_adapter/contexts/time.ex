defmodule CtiKaltura.ProgramScheduling.Time do
  @moduledoc """
  Содержит фукнции для работы со временем.
  """

  @kaltura_date_format_regex ~r/(\d{4,4})(\d{2,2})(\d{2,2})(\d{2,2})(\d{2,2})(\d{2,2})/

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

  @doc """
  Принимает количество часов(integer) и время(NaiveDateTime), относительно которого необходимо вернуть время в прошлом.
  Возвращает NaiveDateTime
  """
  @spec hours_ago(integer, NaiveDateTime.t()) :: NaiveDateTime.t()
  def hours_ago(hours, time \\ nil)
  def hours_ago(hours, nil) when hours > 0, do: hours_ago(hours, NaiveDateTime.utc_now())
  def hours_ago(hours, time) when hours > 0, do: NaiveDateTime.add(time, -3600 * hours, :second)

  @doc """
  Принимает количество секунд(integer) и время(NaiveDateTime), относительно которого необходимо вернуть время в будущем.
  Возвращает NaiveDateTime.
  Если передать значение seconds отрицательным, вернёт время в прошлом.
  """
  @spec seconds_after(integer, NaiveDateTime.t()) :: NaiveDateTime.t()
  def seconds_after(seconds, time \\ nil)
  def seconds_after(seconds, nil), do: seconds_after(seconds, NaiveDateTime.utc_now())
  def seconds_after(seconds, time), do: NaiveDateTime.add(time, seconds, :second)

  @doc """
  Формирует временной интервал в формате ДД.MM.ГГГГ ЧЧ:ММ:СС ± СС с. UTC
  """
  @spec scheduling_time_label(NaiveDateTime.t()) :: binary
  def scheduling_time_label(%NaiveDateTime{} = time) do
    {{year, month, day}, {hours, minutes, seconds}} = NaiveDateTime.to_erl(time)
    "#{day}.#{month}.#{year} #{hours}:#{minutes}:#{seconds}"
  end

  @doc """
  Возвращает время в формате, принимаемом TVE.
  """
  @spec soap_datetime(NaiveDateTime.t()) :: binary
  def soap_datetime(%NaiveDateTime{} = datetime) do
    {{year, month, day}, {hours, minutes, seconds}} = NaiveDateTime.to_erl(datetime)

    "#{year}-#{pad_leading(month)}-#{pad_leading(day)}T#{pad_leading(hours)}:#{
      pad_leading(minutes)
    }:#{pad_leading(seconds)}+00:00"
  end

  defp pad_leading(number), do: String.pad_leading("#{number}", 2, "0")
end
