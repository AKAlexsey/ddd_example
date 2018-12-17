defmodule KalturaServer.DomainModelHandlers.ServerHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Server

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %Server{}
      |> struct(attrs)
      |> Server.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      Server.delete(id)
    end
  end
end
