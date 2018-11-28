defmodule KalturaAdmin.Servers.ServerGroupObserver do
  use Observable, :observer
  alias KalturaAdmin.Servers.ServerGroup

  def handle_notify({:insert, %ServerGroup{}}) do
    IO.puts("! ---> insert has been called ServerGroup")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called ServerGroup")
    :ok
  end

  def handle_notify({:delete, %ServerGroup{}}) do
    IO.puts("! ---> delete has been called ServerGroup")
    :ok
  end
end
