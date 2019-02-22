defmodule KalturaServer.Factory do
  @moduledoc """
  Implementation factory pattern for building domain model table records
  """

  alias KalturaServer.DomainModelFactories.{
    Region,
    Server,
    ServerGroup,
    Subnet,
    LinearChannel,
    TvStream,
    Program,
    ProgramRecord
  }

  Faker.start()

  def insert(table_name, attrs \\ %{})

  def insert(:region, attrs) do
    Region.insert(attrs)
  end

  def insert(:server, attrs) do
    Server.insert(attrs)
  end

  def insert(:server_group, attrs) do
    ServerGroup.insert(attrs)
  end

  def insert(:subnet, attrs) do
    Subnet.insert(attrs)
  end

  def insert(:linear_channel, attrs) do
    LinearChannel.insert(attrs)
  end

  def insert(:tv_stream, attrs) do
    TvStream.insert(attrs)
  end

  def insert(:program, attrs) do
    Program.insert(attrs)
  end

  def insert(:program_record, attrs) do
    ProgramRecord.insert(attrs)
  end

  def insert(model_name, attrs) do
    raise "Unknown model #{inspect(model_name)}, attrs: #{inspect(attrs)}"
  end
end
