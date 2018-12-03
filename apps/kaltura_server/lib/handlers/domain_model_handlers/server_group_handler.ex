defmodule KalturaServer.DomainModelHandlers.ServerGroupHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.ServerGroup

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %ServerGroup{}
      |> struct(attrs)
      |> ServerGroup.write()
    end
    :ok
  end
end
