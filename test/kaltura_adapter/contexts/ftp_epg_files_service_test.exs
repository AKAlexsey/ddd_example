defmodule CtiKaltura.ProgramScheduling.FtpEpgFilesServiceTest do
  use ExUnit.Case, async: false

  alias CtiKaltura.ProgramScheduling.FtpEpgFilesService

  import Mock

  describe "#connection_error_prefix" do
    test "Return right value" do
      assert FtpEpgFilesService.connection_error_prefix() == "FTP Connection problem."
    end
  end

  describe "#with_session" do
    test "Raise error if given wrong host." do
      with_mocks([
        {
          :inets,
          [],
          start: fn _, _ -> {:error, :ehost} end
        }
      ]) do
        assert_raise(RuntimeError, fn ->
          FtpEpgFilesService.with_session({'wronghost', 'user', 'password'}, fn _ -> :ok end)
        end)
      end
    end

    test "Raise error if host is right and credentials is wrong." do
      with_mocks([
        {
          :inets,
          [],
          start: fn _, _ -> {:ok, :pid} end
        },
        {
          :ftp,
          [],
          user: fn _, _, _ -> {:error, :euser} end
        }
      ]) do
        assert_raise(RuntimeError, fn ->
          FtpEpgFilesService.with_session({'host.ru', 'wronguser', 'password'}, fn _ -> :ok end)
        end)

        assert_called(:ftp.user(:pid, 'wronguser', 'password'))
      end
    end
  end

  describe "#set_folders" do
    test "Return :ok if everything allright" do
      with_mocks([
        {
          :ftp,
          [],
          lcd: fn _, _ -> :ok end, cd: fn _, _ -> :ok end
        }
      ]) do
        assert :ok == FtpEpgFilesService.set_folders(:pid, '/local/folder/path', '4cti')
      end
    end

    test "Return error if local files folder does not exist" do
      with_mocks([
        {
          :ftp,
          [],
          lcd: fn _, _ -> {:error, :epath} end, cd: fn _, _ -> :ok end
        }
      ]) do
        assert {:error, "Wrong local files path: /local/folder/path"} ==
                 FtpEpgFilesService.set_folders(:pid, '/local/folder/path', '4cti')
      end
    end

    test "Return error if remote files folder does not exist" do
      with_mocks([
        {
          :ftp,
          [],
          lcd: fn _, _ -> :ok end, cd: fn _, _ -> {:error, :epath} end
        }
      ]) do
        assert {:error, "Wrong remote files path: 4cti"} ==
                 FtpEpgFilesService.set_folders(:pid, '/local/folder/path', '4cti')
      end
    end

    test "Return error is there is problem with connection to ftp" do
      with_mocks([
        {
          :ftp,
          [],
          lcd: fn _, _ -> :ok end, cd: fn _, _ -> {:error, :econn} end
        }
      ]) do
        assert {:error, "Connection to FTP: {:error, :econn}"} ==
                 FtpEpgFilesService.set_folders(:pid, '/local/folder/path', '4cti')
      end
    end
  end

  describe "#query_ftp_files_batch" do
    setup do
      {:ok, pid: :pid}
    end

    test "Query files list, parse response, download files and make right response if everything alright. Restrict queries size.",
         %{pid: pid} do
      remote_ls_query_response =
        'drwxrwxrwx   1 user     group           0 Jun 13 09:20 .\r\ndrwxrwxrwx   1 user     group           0 Jun 13 09:20 ..\r\n-rw-rw-rw-   1 user     group      121457 Jun 11 15:18 file1.xml\r\n-rw-rw-rw-   1 user     group      121977 Jun 11 15:18 file2.xml\r\n'

      with_mocks([
        {:ftp, [],
         nlist: fn _ -> {:ok, remote_ls_query_response} end,
         recv: fn
           ^pid, 'file1.xml' -> :ok
           ^pid, 'file2.xml' -> {:error, :epath}
         end}
      ]) do
        assert {:ok, {['file1.xml'], ["file2.xml with error {:error, :epath}"]}} ==
                 FtpEpgFilesService.query_ftp_files_batch(pid, 10)

        assert {:ok, {['file1.xml'], []}} == FtpEpgFilesService.query_ftp_files_batch(pid, 1)
      end
    end

    test "Query only xml files", %{pid: pid} do
      remote_ls_query_response =
        'drwxrwxrwx   1 user     group           0 Jun 13 09:20 .\r\ndrwxrwxrwx   1 user     group           0 Jun 13 09:20 ..\r\n-rw-rw-rw-   1 user     group      121457 Jun 11 15:18 file1.xml\r\n-rw-rw-rw-   1 user     group      121977 Jun 11 15:18 file2.doc\r\n'

      with_mocks([
        {:ftp, [],
         nlist: fn _ -> {:ok, remote_ls_query_response} end, recv: fn ^pid, 'file1.xml' -> :ok end}
      ]) do
        assert {:ok, {['file1.xml'], []}} == FtpEpgFilesService.query_ftp_files_batch(pid, 10)
      end
    end

    test "Return {:ok, :no_files} if there is not appropriate files", %{pid: pid} do
      remote_ls_query_response =
        'drwxrwxrwx   1 user     group           0 Jun 13 09:20 .\r\ndrwxrwxrwx   1 user     group           0 Jun 13 09:20 ..\r\n-rw-rw-rw-   1 user     group      121457 Jun 11 15:18 file1.doc\r\n-rw-rw-rw-   1 user     group      121977 Jun 11 15:18 file2.doc\r\n'

      with_mocks([
        {
          :ftp,
          [],
          nlist: fn _ -> {:ok, remote_ls_query_response} end
        }
      ]) do
        assert {:ok, :no_files} == FtpEpgFilesService.query_ftp_files_batch(pid, 10)
      end
    end

    test "Return error if can't query ", %{pid: pid} do
      with_mocks([
        {
          :ftp,
          [],
          nlist: fn _ -> {:error, :econn} end
        }
      ]) do
        assert {:error, {:error, :econn}} == FtpEpgFilesService.query_ftp_files_batch(pid, 10)
      end
    end
  end

  describe "#delete_ftp_file" do
    test "Remove given file in given folder if they exist" do
      with_mocks([
        {
          :ftp,
          [],
          delete: fn :pid, 'file1.xml' -> :ok end, cd: fn :pid, _ -> :ok end
        }
      ]) do
        assert :ok == FtpEpgFilesService.delete_ftp_file(:pid, '4cti', 'file1.xml')
      end
    end

    test "Return error if remote folder does not exist" do
      with_mocks([
        {
          :ftp,
          [],
          cd: fn :pid, '4cti' -> {:error, :epath} end
        }
      ]) do
        assert {:error, :epath} == FtpEpgFilesService.delete_ftp_file(:pid, '4cti', 'file1.xml')
      end
    end

    test "Return error if file does not exist" do
      with_mocks([
        {
          :ftp,
          [],
          cd: fn :pid, _ -> :ok end, delete: fn :pid, 'file1.xml' -> {:error, :epath} end
        }
      ]) do
        assert {:error, :epath} == FtpEpgFilesService.delete_ftp_file(:pid, '4cti', 'file1.xml')
      end
    end
  end

  describe "#close_connection" do
    test "Run :inets.stop()" do
      with_mocks([{:inets, [], stop: fn :ftpc, _pid -> :ok end}]) do
        FtpEpgFilesService.close_connection(:pid)
        assert_called(:inets.stop(:ftpc, :pid))
      end
    end
  end
end
