defmodule KalturaServer.DomainModelHandlers.ProgramHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Program

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %Program{}
      |> struct(attrs)
      |> Program.write()
    end
    :ok
  end
end
