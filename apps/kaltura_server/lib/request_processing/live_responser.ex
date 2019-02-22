defmodule KalturaServer.RequestProcessing.LiveResponser do
  @moduledoc """
  Contains logic for processing LIVE request.
  """

  import Plug.Conn
  alias KalturaServer.ClosestEdgeServerService
  alias KalturaServer.DomainModelContext, as: Context

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_resource_params()
    |> put_server_domain_data()
    |> live_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  defp put_resource_params(
         {%Plug.Conn{assigns: %{resource_id: epg_id, protocol: protocol, encryption: encryption}} =
            conn, data}
       ) do
    with %{id: id, tv_stream_ids: tv_stream_ids} <- Context.find_linear_channel(epg_id),
         [_ | _] = tv_streams <- Context.find_tv_streams(tv_stream_ids, protocol),
         %{stream_path: stream_path} <-
           find_most_appropriate_tv_stream(tv_streams, protocol, encryption) do
      enriched_data =
        data
        |> Map.merge(%{
          stream_path: stream_path,
          protocol: protocol,
          encryption: encryption,
          linear_channel_id: id
        })

      {conn, enriched_data}
    else
      _ ->
        {conn, data}
    end
  end

  defp find_most_appropriate_tv_stream(tv_streams, "mpd", "wv") do
    with nil <- find_tv_stream_with_encryption(tv_streams, "WIDEVINE"),
         nil <- find_tv_stream_with_encryption(tv_streams, "COMMON") do
      nil
    else
      tv_stream -> tv_stream
    end
  end

  defp find_most_appropriate_tv_stream(tv_streams, "mpd", "pr") do
    with nil <- find_tv_stream_with_encryption(tv_streams, "PLAYREADY"),
         nil <- find_tv_stream_with_encryption(tv_streams, "COMMON") do
      nil
    else
      tv_stream -> tv_stream
    end
  end

  defp find_most_appropriate_tv_stream(tv_streams, _, _) do
    find_tv_stream_with_encryption(tv_streams, "NONE")
  end

  defp find_tv_stream_with_encryption(tv_streams, encryption) do
    Enum.find(tv_streams, fn %{encryption: enc} -> enc == Context.normalize_enum(encryption) end)
  end

  defp put_server_domain_data(
         {%Plug.Conn{assigns: %{ip_address: ip_address}} = conn,
          %{linear_channel_id: linear_channel_id} = data}
       ) do
    case ClosestEdgeServerService.perform(ip_address, linear_channel_id: linear_channel_id) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({conn, data}), do: {conn, data}

  defp live_response(
         {conn, %{domain_name: _, port: _, protocol: _, encryption: _, stream_path: _} = data}
       ) do
    {
      put_resp_header(conn, "location", make_live_redirect_path(data)),
      302,
      ""
    }
  end

  defp live_response({conn, _data}) do
    {conn, 500, "Server not found"}
  end

  defp make_live_redirect_path(%{
         domain_name: domain_name,
         port: port,
         protocol: protocol,
         encryption: encryption,
         stream_path: stream_path
       }) do
    "http://#{domain_name}#{server_port(port)}/#{codec_path(protocol, encryption)}/#{stream_path}"
  end

  defp server_port(80), do: ""
  defp server_port(port), do: ":#{port}"

  defp codec_path(protocol, ""), do: protocol
  defp codec_path(protocol, encryption), do: "#{protocol}_#{encryption}"
end
