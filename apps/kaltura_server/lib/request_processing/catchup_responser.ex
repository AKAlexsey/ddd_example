defmodule KalturaServer.RequestProcessing.CatchupResponser do
  @moduledoc """
  Contains logic for processing CATCHUP request.
  """

  import Plug.Conn
  alias KalturaServer.ClosestEdgeServerService
  alias KalturaServer.DomainModelContext, as: Context

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_resource_params()
    |> put_server_domain_data()
    |> catchup_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  defp put_resource_params(
         {%Plug.Conn{assigns: %{resource_id: epg_id, protocol: protocol}} = conn, data}
       ) do
    with %{id: program_id} <- Context.find_program(epg_id),
         %{server_id: server_id, status: :completed, path: path} <-
           Context.find_program_record(program_id, protocol),
         %{prefix: prefix} <- Context.find_dvr_server(server_id) do
      enriched_data =
        data
        |> Map.merge(%{
          record_path: path,
          dvr_server_prefix: prefix
        })

      {conn, enriched_data}
    else
      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({
         %Plug.Conn{assigns: %{ip_address: ip_address}} = conn,
         data
       }) do
    case ClosestEdgeServerService.perform(ip_address) do
      %{domain_name: domain_name, port: port} ->
        {conn, Map.merge(data, %{domain_name: domain_name, port: port})}

      _ ->
        {conn, data}
    end
  end

  defp catchup_response(
         {conn, %{domain_name: _, port: _, dvr_server_prefix: _, record_path: _} = data}
       ) do
    {
      put_resp_header(conn, "location", make_catchup_redirect_path(data)),
      302,
      ""
    }
  end

  defp catchup_response({conn, _data}) do
    {conn, 404, "Server not found"}
  end

  defp make_catchup_redirect_path(%{
         domain_name: domain_name,
         port: port,
         dvr_server_prefix: prefix,
         record_path: record_path
       }) do
    {application_layer_protocol, server_port} = get_server_port(port)
    "#{application_layer_protocol}://#{domain_name}#{server_port}/dvr/#{prefix}/#{record_path}"
  end

  defp get_server_port(80), do: {"http", ""}
  defp get_server_port(443), do: {"https", ""}
  defp get_server_port(port), do: {"http", ":#{port}"}
end
