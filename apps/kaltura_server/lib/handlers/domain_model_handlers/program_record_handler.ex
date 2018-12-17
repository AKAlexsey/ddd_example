defmodule KalturaServer.DomainModelHandlers.ProgramRecordHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.ProgramRecord

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      %ProgramRecord{}
      |> struct(attrs)
      |> ProgramRecord.write()
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      ProgramRecord.delete(id)
    end
  end
end
