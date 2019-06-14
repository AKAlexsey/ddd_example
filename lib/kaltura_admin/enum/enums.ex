defmodule CtiKaltura.Enums do
  @moduledoc false

  alias CtiKaltura.Content.LinearChannel

  def statuses, do: ["ACTIVE", "INACTIVE"]
  def server_types, do: ["EDGE", "DVR"]
  def stream_protocols, do: ["HLS", "MPD"]
  def encryptions, do: ["NONE", "CENC", "WIDEVINE", "PLAYREADY"]
  def recording_statuses, do: ["NEW", "PLANNED", "RUNNING", "COMPLETED", "ERROR"]
  def roles, do: ["ADMIN", "MANAGER"]

  def storage_id_range do
    [nil] ++
      Enum.to_list(
        LinearChannel.minimum_storage_id_value()..LinearChannel.maximum_storage_id_value()
      )
  end
end
