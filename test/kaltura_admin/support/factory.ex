defmodule CtiKaltura.Factory do
  @moduledoc """
  Implements Factory pattern for using in tests
  """
  Faker.start()

  alias CtiKaltura.{
    LinearChannelFactory,
    ProgramFactory,
    ProgramRecordFactory,
    RegionFactory,
    ServerFactory,
    ServerGroupFactory,
    SubnetFactory,
    TvStreamFactory,
    UserFactory
  }

  @spec build(atom, map()) :: {:ok, any()} | {:error, any()}
  def build(model, attrs \\ %{}), do: build_implementation(model, attrs)

  defp build_implementation(:user, attrs) do
    UserFactory.build(attrs)
  end

  defp build_implementation(:admin, attrs) do
    UserFactory.build_admin(attrs)
  end

  defp build_implementation(:linear_channel, attrs) do
    LinearChannelFactory.build(attrs)
  end

  defp build_implementation(:tv_stream, attrs) do
    TvStreamFactory.build(attrs)
  end

  defp build_implementation(:program, attrs) do
    ProgramFactory.build(attrs)
  end

  defp build_implementation(:program_record, attrs) do
    ProgramRecordFactory.build(attrs)
  end

  defp build_implementation(:server, attrs) do
    ServerFactory.build(attrs)
  end

  defp build_implementation(:server_group, attrs) do
    ServerGroupFactory.build(attrs)
  end

  defp build_implementation(:region, attrs) do
    RegionFactory.build(attrs)
  end

  defp build_implementation(:subnet, attrs) do
    SubnetFactory.build(attrs)
  end

  @spec insert(atom, map()) :: {:ok, any()} | {:error, any()}
  def insert(model, attrs \\ %{}), do: insert_implementation(model, attrs)

  defp insert_implementation(:admin, attrs) do
    UserFactory.insert_admin(attrs)
  end

  defp insert_implementation(:user, attrs) do
    UserFactory.insert(attrs)
  end

  defp insert_implementation(:linear_channel, attrs) do
    LinearChannelFactory.insert(attrs)
  end

  defp insert_implementation(:tv_stream, attrs) do
    TvStreamFactory.insert(attrs)
  end

  defp insert_implementation(:program, attrs) do
    ProgramFactory.insert(attrs)
  end

  defp insert_implementation(:program_record, attrs) do
    ProgramRecordFactory.insert(attrs)
  end

  defp insert_implementation(:server, attrs) do
    ServerFactory.insert(attrs)
  end

  defp insert_implementation(:server_group, attrs) do
    ServerGroupFactory.insert(attrs)
  end

  defp insert_implementation(:region, attrs) do
    RegionFactory.insert(attrs)
  end

  defp insert_implementation(:subnet, attrs) do
    SubnetFactory.insert(attrs)
  end

  @spec insert_and_notify(atom, map()) :: {:ok, any()} | {:error, any()}
  def insert_and_notify(model, attrs \\ %{}), do: insert_and_notify_implementation(model, attrs)

  defp insert_and_notify_implementation(:admin, attrs) do
    UserFactory.insert_and_notify_admin(attrs)
  end

  defp insert_and_notify_implementation(:user, attrs) do
    UserFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:linear_channel, attrs) do
    LinearChannelFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:tv_stream, attrs) do
    TvStreamFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:program, attrs) do
    ProgramFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:program_record, attrs) do
    ProgramRecordFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:server, attrs) do
    ServerFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:server_group, attrs) do
    ServerGroupFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:region, attrs) do
    RegionFactory.insert_and_notify(attrs)
  end

  defp insert_and_notify_implementation(:subnet, attrs) do
    SubnetFactory.insert_and_notify(attrs)
  end
end
