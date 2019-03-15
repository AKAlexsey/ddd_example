defmodule KalturaServer.RequestProcessing.VodResponser do
  @moduledoc """
  Contains logic for processing VOD request.
  """

  import Plug.Conn
  alias KalturaServer.ClosestEdgeServerService

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_path_params()
    |> put_server_domain_data()
    |> vod_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  defp put_path_params({%Plug.Conn{assigns: %{vod_path: vod_path}} = conn, data}) do
    {conn, Map.put(data, :vod_path, vod_path)}
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

  defp vod_response({conn, %{domain_name: _, port: _, vod_path: _} = data}) do
    {
      put_resp_header(conn, "Location", make_live_redirect_path(data)),
      302,
      ""
    }
  end

  defp vod_response({conn, _data}) do
    {conn, 404, "Server not found"}
  end

  defp make_live_redirect_path(%{
         domain_name: domain_name,
         port: port,
         vod_path: vod_path
       }) do
    {application_layer_protocol, server_port} = get_server_port(port)
    "#{application_layer_protocol}://#{domain_name}#{server_port}/vod/#{vod_path}"
  end

  defp get_server_port(80), do: {"http", ""}
  defp get_server_port(443), do: {"https", ""}
  defp get_server_port(port), do: {"http", ":#{port}"}
end
