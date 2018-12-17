defmodule KalturaServer.DomainModelHandlers.ProgramHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Program

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %Program{}
      |> struct(attrs)
      |> Program.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      Program.delete(id)
    end
  end
end
