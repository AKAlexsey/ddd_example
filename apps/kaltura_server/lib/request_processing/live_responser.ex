defmodule KalturaServer.RequestProcessing.LiveResponser do
  @moduledoc """
  Contains logic for processing LIVE request.
  """

  import Plug.Conn
  alias KalturaServer.ClosestEdgeServerService
  alias KalturaServer.DomainModelContext, as: Context
  alias KalturaServer.RequestProcessing.RequestHelper

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
    approp_rec =
      Context.find_tv_streams(epg_id, protocol)
      |> RequestHelper.obtain_entity_by_encryption(RequestHelper.normalize_encryption(encryption))

    case approp_rec do
      nil -> {conn, data}
      _ -> {conn, data |> Map.merge(%{stream_path: approp_rec.stream_path})}
    end
  end

  defp put_server_domain_data({%Plug.Conn{assigns: %{ip_address: ip_address}} = conn, data}) do
    case ClosestEdgeServerService.perform(ip_address) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({conn, data}), do: {conn, data}

  defp live_response({conn, %{domain_name: _, port: _, stream_path: _} = data}) do
    {
      put_resp_header(conn, "Location", make_live_redirect_path(data)),
      302,
      ""
    }
  end

  defp live_response({conn, _data}) do
    {conn, 404, "Server not found"}
  end

  defp make_live_redirect_path(%{
         domain_name: domain_name,
         port: port,
         stream_path: stream_path
       }) do
    {application_layer_protocol, server_port} = get_server_port(port)
    "#{application_layer_protocol}://#{domain_name}#{server_port}/#{stream_path}"
  end

  defp get_server_port(80), do: {"http", ""}
  defp get_server_port(443), do: {"https", ""}
  defp get_server_port(port), do: {"http", ":#{port}"}
end
