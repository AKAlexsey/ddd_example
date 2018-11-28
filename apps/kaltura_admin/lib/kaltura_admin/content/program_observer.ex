defmodule KalturaAdmin.Content.ProgramObserver do
  use Observable, :observer
  alias KalturaAdmin.Content.Program

  def handle_notify({:insert, %Program{}}) do
    IO.puts("! ---> insert has been called Program")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called Program")
    :ok
  end

  def handle_notify({:delete, %Program{}}) do
    IO.puts("! ---> delete has been called Program")
    :ok
  end
end
