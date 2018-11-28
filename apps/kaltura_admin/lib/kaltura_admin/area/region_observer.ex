defmodule KalturaAdmin.Area.RegionObserver do
  use Observable, :observer
  alias KalturaAdmin.Area.Region

  def handle_notify({:insert, %Region{}}) do
    IO.puts("! ---> insert has been called Region")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called Region")
    :ok
  end

  def handle_notify({:delete, %Region{}}) do
    IO.puts("! ---> delete has been called Region")
    :ok
  end
end
