defmodule KalturaAdmin.Area.SubnetObserver do
  use Observable, :observer
  alias KalturaAdmin.Area.Subnet

  def handle_notify({:insert, %Subnet{}}) do
    IO.puts("! ---> insert has been called Subnet")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called Subnet")
    :ok
  end

  def handle_notify({:delete, %Subnet{}}) do
    IO.puts("! ---> delete has been called Subnet")
    :ok
  end
end
