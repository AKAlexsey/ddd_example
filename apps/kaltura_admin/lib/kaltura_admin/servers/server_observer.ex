defmodule KalturaAdmin.Servers.ServerObserver do
  use Observable, :observer
  alias KalturaAdmin.Servers.Server

  def handle_notify({:insert, %Server{}}) do
    IO.puts("! ---> insert has been called Server")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called Server")
    :ok
  end

  def handle_notify({:delete, %Server{}}) do
    IO.puts("! ---> delete has been called Server")
    :ok
  end
end
