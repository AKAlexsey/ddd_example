defmodule KalturaAdmin.EnumHelper do
  @moduledoc """
  Contains repeating functions for using enums
  """

  alias KalturaAdmin.{ServerType, ActiveStatus, RecordingStatus, StreamProtocol}

  def server_types, do: enum_for_select(ServerType)
  def active_statuses, do: enum_for_select(ActiveStatus)
  def recording_statuses, do: enum_for_select(RecordingStatus)
  def stream_protocols, do: enum_for_select(StreamProtocol)

  defp enum_for_select(module) do
    module.__enum_map__()
    |> Enum.map(fn {key, _code} -> {to_string(key), to_string(key)} end)
  end
end
