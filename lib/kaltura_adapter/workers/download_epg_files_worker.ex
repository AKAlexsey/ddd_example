defmodule CtiKaltura.ProgramScheduling.DownloadEpgFilesWorker do
  @moduledoc """
  Осуществляет скачивание файлов с FTP и последующее их удаление.
  """

  use CtiKaltura.ProgramScheduling.IntervalWorker,
    logging_domain: :epg_files,
    configuration_alias: :epg_files_downloading

  alias CtiKaltura.ProgramScheduling.FtpEpgFilesService

  @connection_error_prefix FtpEpgFilesService.connection_error_prefix()

  def delete_file_from_ftp_host(file_name) do
    GenServer.cast(via_tuple(__MODULE__), {:delete_file, file_name})
  end

  def useful_job do
    FtpEpgFilesService.with_session({ftp_host(), ftp_user(), ftp_password()}, fn pid ->
      with :ok <- FtpEpgFilesService.set_folders(pid, local_files_folder(), ftp_folder()),
           {:ok, {success_files, error_files}} <-
             FtpEpgFilesService.query_ftp_files_batch(pid, batch_size()) do
        log_info(
          "Files has been downloaded from FTP.\nSuccess: #{inspect(success_files)}\nFails: #{
            inspect(error_files)
          }"
        )
      else
        {:error, reason} ->
          log_error("Error during requesting files: #{inspect(reason)}")

        {:ok, :no_files} ->
          log_info("No files")
          :ok
      end
    end)
  catch
    :error, %RuntimeError{message: @connection_error_prefix <> message} ->
      log_error(@connection_error_prefix <> message)
  end

  def handle_cast({:delete_file, file_name}, state) do
    if delete_downloaded_files() do
      log_info("Removing #{file_name} from remote host")

      FtpEpgFilesService.with_session({ftp_host(), ftp_user(), ftp_password()}, fn pid ->
        case FtpEpgFilesService.delete_ftp_file(pid, ftp_folder(), file_name) do
          :ok ->
            log_info("File removed #{file_name} from #{ftp_host()}/#{ftp_folder()}")

          {:error, reason} ->
            log_error("Error during removing file #{file_name}: #{reason}")
        end
      end)

      {:noreply, state}
    else
      log_info("Removing #{file_name}. Cancelled because deleting downloaded files switched off.")
      {:noreply, state}
    end
  catch
    :error, %RuntimeError{message: @connection_error_prefix <> message} ->
      log_error(@connection_error_prefix <> message)
  end

  # Configuration functions
  defp batch_size, do: config()[:batch_size]
  defp ftp_folder, do: config()[:ftp_folder]
  defp ftp_host, do: config()[:ftp_host]
  defp ftp_password, do: config()[:ftp_password]
  defp ftp_user, do: config()[:ftp_user]
  defp delete_downloaded_files, do: config()[:delete_downloaded_files]

  defp local_files_folder do
    Application.get_env(:cti_kaltura, :epg_file_parser)[:files_directory]
  end
end
