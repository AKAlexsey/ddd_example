defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Subnet

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %Subnet{}
      |> struct(attrs)
      |> Subnet.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      Subnet.delete(id)
    end
  end
end
