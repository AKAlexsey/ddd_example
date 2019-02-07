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
         {%Plug.Conn{assigns: %{resource_id: epg_id, protocol: protocol}} = conn, data}
       ) do
    case Context.find_tv_stream(epg_id, protocol) do
      %{id: id, stream_path: stream_path} ->
        enriched_data =
          data
          |> Map.merge(%{
            stream_path: stream_path,
            protocol: protocol,
            tv_stream_id: id
          })

        {conn, enriched_data}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data(
         {%Plug.Conn{assigns: %{ip_address: ip_address}} = conn,
          %{tv_stream_id: tv_stream_id} = data}
       ) do
    case ClosestEdgeServerService.perform(ip_address, tv_stream_id: tv_stream_id) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({conn, data}), do: {conn, data}

  defp live_response({conn, %{domain_name: _, port: _, protocol: _, stream_path: _} = data}) do
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
         stream_path: stream_path
       }) do
    "http://#{domain_name}#{server_port(port)}/#{protocol}/#{stream_path}"
  end

  defp server_port(80), do: ""
  defp server_port(port), do: ":#{port}"
end
