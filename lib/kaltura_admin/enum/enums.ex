defmodule CtiKaltura.Enums do
  @moduledoc false

  def statuses, do: ["ACTIVE", "INACTIVE"]
  def server_types, do: ["EDGE", "DVR"]
  def stream_protocols, do: ["HLS", "MPD"]
  def encryptions, do: ["NONE", "CENC", "WIDEVINE", "PLAYREADY"]
  def recording_statuses, do: ["NEW", "PLANNED", "RUNNING", "COMPLETED", "ERROR"]
  def roles, do: ["ADMIN", "MANAGER"]
end
