defmodule KalturaServer.Handlers.DomainModelHandler do
  @moduledoc """
  Handle notifications after Create Update Delete events with database.
  """
  require Amnesia
  require Amnesia.Helper

  alias KalturaServer.Handlers.AbstractHandler

  alias DomainModel.{
    Program,
    ProgramRecord,
    Region,
    ServerGroup,
    Server,
    Subnet,
    TvStream
  }

  @behaviour AbstractHandler

  def handle(event, %{model_name: "Program", attrs: attrs}) do
    process_event(Program, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "ProgramRecord", attrs: attrs}) do
    process_event(ProgramRecord, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "Region", attrs: attrs}) do
    process_event(Region, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "ServerGroup", attrs: attrs}) do
    process_event(ServerGroup, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "Server", attrs: attrs}) do
    process_event(Server, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "Subnet", attrs: attrs}) do
    process_event(Subnet, event, attrs)
    :ok
  end

  def handle(event, %{model_name: "TvStream", attrs: attrs}) do
    process_event(TvStream, event, attrs)
    :ok
  end

  def handle(event, %{model_name: name, attrs: attrs}) do
    raise "KalturaServer.Handlers.DomainModelHandler unknown model name #{inspect(name)} event: #{
            event
          } attrs #{inspect(attrs)}"

    :ok
  end

  defp process_event(table, event, attrs) when event in [:insert, :update, :refresh] do
    Amnesia.transaction do
      table.__struct__()
      |> struct(attrs)
      |> table.write()
    end

    :ok
  end

  defp process_event(table, :delete, %{id: id}) do
    Amnesia.transaction do
      table.delete(id)
    end
  end
end
