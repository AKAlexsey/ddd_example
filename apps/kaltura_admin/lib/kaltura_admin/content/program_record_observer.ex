defmodule KalturaAdmin.Content.ProgramRecordObserver do
  use Observable, :observer
  alias KalturaAdmin.Content.ProgramRecord

  def handle_notify({:insert, %ProgramRecord{}}) do
    IO.puts("! ---> insert has been called ProgramRecord")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called ProgramRecord")
    :ok
  end

  def handle_notify({:delete, %ProgramRecord{}}) do
    IO.puts("! ---> delete has been called ProgramRecord")
    :ok
  end
end
