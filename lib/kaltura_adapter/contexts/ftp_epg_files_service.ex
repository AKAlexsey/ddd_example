defmodule CtiKaltura.ProgramScheduling.FtpEpgFilesService do
  @moduledoc """
  Содерижт функции, для скачивания файлов с FTP.
  """

  @connection_error_prefix "FTP Connection problem."
  @epg_file_regex ~r/[\w\d]+\.xml/

  @spec connection_error_prefix :: binary
  def connection_error_prefix, do: @connection_error_prefix

  @doc """
  1. Осуществляет авторизацию на FTP;
  2. Затем производит переход в папку, в которой лежат EPG файлы;
  3. В случае успешной авторизации, выполняет переданную вторым паргументом функцию с арностью 1.
  В качестве аргумента передаёт PID Inets процесса.
  """
  @spec with_session({binary, binary, binary}, function) :: {:ok, pid} | {:error, any()}
  def with_session({host, user, password}, session_function) do
    with {:ok, pid} <- :inets.start(:ftpc, host: host),
         :ok <- :ftp.user(pid, user, password) do
      session_function.(pid)
      close_connection(pid)
    else
      {:error, :inets_not_started} ->
        :inets.start()
        with_session({host, user, password}, session_function)

      {:error, :ehost} ->
        raise("#{connection_error_prefix()}Wrong FTP host #{host}")

      {:error, :euser} ->
        raise(
          "#{connection_error_prefix()}Wrong FTP authentication credentials. User #{user}, password #{
            password
          }"
        )
    end
  end

  @doc """
  Принимает pid Inets процесса, название папки, где на FTP сервере лежат файлы и путь до папки, куда будут
  класться скачанные файлы. Устанавливает для процесса папки откуда и куда будут скачиваться файлы.
  """
  @spec set_folders(pid, binary, binary) :: :ok | {:error, any}
  def set_folders(pid, local_files_folder, remote_files_folder) do
    with {:local, :ok} <- {:local, :ftp.lcd(pid, local_files_folder)},
         {:remote, :ok} <- {:remote, safe_cd(pid, remote_files_folder)} do
      :ok
    else
      {:local, {:error, :epath}} ->
        {:error, "Wrong local files path: #{local_files_folder}"}

      {:remote, {:error, :epath}} ->
        {:error, "Wrong remote files path: #{remote_files_folder}"}

      {:remote, {:error, reason}} ->
        {:error, "Connection to FTP: #{inspect({:error, reason})}"}
    end
  end

  @doc """
  Принимает pid Inets процесса и количество файлов, которые будут скачанны с FTP сервера.
  Результат функции описывается следующими спецификациями:
  1. {:ok, :no_files} - если новых файлов нет;
  2. {:ok, {success_files_list, error_files_list}} - `success_files_list` - список успешно скачанных файлов.
  `error_files_list` - список неуспешно скачанных файлов;
  3. {:error, any} - если в процессе, возникла ошибка.
  """
  @spec query_ftp_files_batch(pid, integer) ::
          {:ok, :no_files} | {:ok, {list, list}} | {:error, any}
  def query_ftp_files_batch(pid, batch_size) do
    with {:ok, ls_result} <- :ftp.nlist(pid),
         epg_files <- epg_files_list(ls_result),
         batch_epg_files when length(batch_epg_files) > 0 <- Enum.take(epg_files, batch_size),
         files_download_result <- download_files(pid, batch_epg_files) do
      make_response(files_download_result)
    else
      [] ->
        {:ok, :no_files}

      error ->
        {:error, error}
    end
  end

  defp epg_files_list(ls_result) do
    ls_result
    |> to_charlist()
    |> to_string()
    |> String.split("\n")
    |> Enum.filter(fn file_string ->
      Regex.match?(@epg_file_regex, file_string)
    end)
    |> Enum.map(fn file ->
      @epg_file_regex
      |> Regex.run(file)
      |> hd()
      |> to_charlist()
    end)
  end

  defp download_files(pid, epg_files) do
    epg_files
    |> Enum.map(fn file ->
      {file, :ftp.recv(pid, file)}
    end)
  end

  defp make_response(files_download_result) do
    {success_files, error_files} =
      files_download_result
      |> Enum.reduce({[], []}, fn
        {file_name, :ok}, {success_list, error_list} ->
          {success_list ++ [file_name], error_list}

        {file_name, error}, {success_list, error_list} ->
          {success_list, error_list ++ ["#{file_name} with error #{inspect(error)}"]}
      end)

    {:ok, {success_files, error_files}}
  end

  @doc """
  Принимает pid Inets процесса и список файлов и удаляет их с FTP сервера.
  """
  @spec delete_ftp_file(pid, binary, binary) :: :ok | {:error, binary}
  def delete_ftp_file(pid, remote_file_folder, file_name) do
    with :ok <- safe_cd(pid, remote_file_folder),
         :ok <- :ftp.delete(pid, file_name) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Принимает pid Inets процесса и закрывает соединение.
  """
  @spec close_connection(pid) :: :ok | {:error, binary}
  def close_connection(pid) do
    :inets.stop(:ftpc, pid)
  end

  defp safe_cd(_pid, ''), do: :ok
  defp safe_cd(pid, remote_file_folder), do: :ftp.cd(pid, remote_file_folder)
end
