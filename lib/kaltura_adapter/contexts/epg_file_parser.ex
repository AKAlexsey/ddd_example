defmodule CtiKaltura.ProgramScheduling.EpgFileParser do
  @moduledoc """
  Содержит функции для парсинга EPG файлов.
  """

  import SweetXml

  @channel_epg_id_sigil ~x"//channel/@id"
  @program_epg_id_sigil ~x"@external_id"e
  @program_name_sigil ~x"//title/text()"s
  @program_sigil ~x"/EpgChannels/programme"l
  @start_time_sigil ~x"@start"e
  @stop_time_sigil ~x"@stop"e

  @doc """
  Принимает папку, в которой лежат все EPG файлы.
  Возвращает случайный файл из папки, сообщение об отсутсвии файлов или ошибку чтения.

  Ошибка соответствует ошибкам File.read()
  :enoent - the file does not exist
  :eacces - missing permission for reading the file, or for searching one of the parent directories
  :eisdir - the named file is a directory
  :enotdir - a component of the file name is not a directory; on some platforms, :enoent is returned instead
  :enomem
  """
  @spec one_file_data(binary, binary) ::
          {:ok, %{linear_channel: map(), programs: list(map())}}
          | {:ok, :no_file}
          | {:error, atom}
  def one_file_data(files_dir, processed_files_directory) do
    with file_path when is_binary(file_path) <- get_first_file(files_dir),
         {:ok, file} <- File.read(file_path),
         linear_channel <- get_linear_channel(file),
         programs_list <- get_programs_data(file) do
      move_file_to_processed(file_path, processed_files_directory)
      {:ok, %{linear_channel: linear_channel, programs: programs_list}}
    else
      :no_file -> {:ok, :no_file}
      {:error, reason} -> {:error, reason}
    end
  catch
    :exit, _ ->
      invalid_file = get_first_file(files_dir)
      move_file_to_processed(invalid_file, processed_files_directory)
      new_invalid_file_name = "#{processed_files_directory}/#{Path.basename(invalid_file)}"

      {:error, {:file_invalid, new_invalid_file_name}}
  end

  @doc """
  Возвращает первый XML файл из папки или :no_file
  """
  @spec get_first_file(binary) :: binary | :no_file
  def get_first_file(files_dir) do
    case Path.wildcard("#{files_dir}/*.xml") do
      [] -> :no_file
      files_list -> Enum.at(files_list, 0)
    end
  end

  @doc """
  Принимает EPG файл и возвращает %{epg_id: binary}
  """
  @spec get_linear_channel(binary) :: %{epg_id: binary}
  def get_linear_channel(file) do
    %{epg_id: "#{xpath(file, @channel_epg_id_sigil)}"}
  end

  @doc """
  Принимает файл и возвращает список данных по программам с полями:
  [%{epg_id: binary, start_time: binary, end_time: binary}]
  """
  @spec get_programs_data(binary) :: list(map())
  def get_programs_data(file) do
    file
    |> xpath(
      @program_sigil,
      epg_id: @program_epg_id_sigil,
      start_datetime: @start_time_sigil,
      end_datetime: @stop_time_sigil,
      name: @program_name_sigil
    )
    |> clarify_program_data()
  end

  defp clarify_program_data(programs) do
    programs
    |> Enum.map(fn raw_program_map ->
      raw_program_map
      |> Enum.reduce(%{}, fn {key, value}, result ->
        Map.put(result, key, extract_value(value))
      end)
    end)
  end

  defp extract_value(value_tuple) when is_tuple(value_tuple) do
    value_tuple
    |> Tuple.to_list()
    |> Enum.at(-2)
    |> (fn charlist_value -> "#{charlist_value}" end).()
  end

  defp extract_value(value), do: value

  @doc """
  Перемещает файл в папку, где хранятся обработанные файлы.
  """
  def move_file_to_processed(file_path, processed_directory) do
    File.cp(file_path, "#{processed_directory}/#{Path.basename(file_path)}")
    File.rm(file_path)
  end
end
