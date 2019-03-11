defmodule KalturaServer.DomainModelHandlers.ProgramHandler do
  @moduledoc false

  alias DomainModel.Program

  use KalturaServer.DomainModelHandlers.AbstractHandler, table: Program
end
