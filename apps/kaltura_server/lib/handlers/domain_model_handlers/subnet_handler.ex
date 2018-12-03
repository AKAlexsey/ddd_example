defmodule KalturaServer.DomainModelHandlers.SubnetHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Subnet

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %Subnet{}
      |> struct(attrs)
      |> Subnet.write()
    end
    :ok
  end
end
