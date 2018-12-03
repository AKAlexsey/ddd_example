defmodule KalturaServer.DomainModelHandlers.ProgramRecordHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.ProgramRecord

  def handle(action, attrs) when action in [:insert, :update] do
    Amnesia.transaction do
      %ProgramRecord{}
      |> struct(attrs)
      |> ProgramRecord.write()
    end
    :ok
  end
end
