defmodule KalturaServer.RequestProcessing.CatchupResponser do
  @moduledoc """
  Contains logic for processing CATCHUP request.
  """

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, 500, "Server not found"}
  end
end
