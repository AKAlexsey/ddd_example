defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.TvStream

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %TvStream{}
      |> struct(attrs)
      |> TvStream.write()
    end
    :ok
  end
end
