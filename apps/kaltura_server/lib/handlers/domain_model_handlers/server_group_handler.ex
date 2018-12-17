defmodule KalturaServer.DomainModelHandlers.ServerGroupHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.ServerGroup

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %ServerGroup{}
      |> struct(attrs)
      |> ServerGroup.write()
    end

    :ok
  end

  def handle(:refresh_by_request, attrs) do
    Amnesia.transaction do
      %ServerGroup{}
      |> struct(attrs)
      |> ServerGroup.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      ServerGroup.delete(id)
    end
  end
end
