defmodule KalturaServer.RequestProcessing.Responser do
  import Plug.Conn

  alias KalturaServer.Caching.Channels

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(
        %Plug.Conn{assigns: %{ip_address: _ip_address, query: %{"channel" => channel}}} = conn
      ) do
    case Channels.find_channel_url(channel) do
      {:ok, url} ->
        {
          put_resp_header(conn, "location", url),
          302,
          ""
        }

      {:error, :not_found} ->
        {conn, 422, "no_url for channel #{channel}"}
    end
  end

  def make_response(conn), do: {conn, 422, "no_channel_param"}
end
