defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.TvStream

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %TvStream{}
      |> struct(attrs)
      |> TvStream.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      TvStream.delete(id)
    end
  end
end
