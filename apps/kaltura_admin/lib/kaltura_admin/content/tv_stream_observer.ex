defmodule KalturaAdmin.Content.TvStreamObserver do
  use Observable, :observer
  alias KalturaAdmin.Content.TvStream

  def handle_notify({:insert, %TvStream{}}) do
    IO.puts("! ---> insert has been called TvStream")
    :ok
  end

  def handle_notify({:update, [old_record, new_record]}) do
    IO.puts("! ---> update has been called TvStream")
    :ok
  end

  def handle_notify({:delete, %TvStream{}}) do
    IO.puts("! ---> delete has been called TvStream")
    :ok
  end
end
