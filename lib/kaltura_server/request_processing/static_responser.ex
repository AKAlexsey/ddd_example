defmodule CtiKaltura.RequestProcessing.StaticResponser do
  @moduledoc """
  Contains logic for processing STATIC-content requests.
  """

  use CtiKaltura.KalturaLogger, metadata: [domain: :request]

  import Plug.Conn
  alias CtiKaltura.ClosestEdgeServerService
  alias CtiKaltura.Util.ServerUtil

  @spec make_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_response(%Plug.Conn{} = conn) do
    {conn, %{}}
    |> put_server_domain_data()
    |> prepare_response()
  end

  def make_response(conn) do
    {conn, 400, "Request invalid"}
  end

  defp put_server_domain_data({%Plug.Conn{assigns: %{ip_address: ip_address}} = conn, data}) do
    case ClosestEdgeServerService.perform(ip_address) do
      %{domain_name: domain_name} ->
        {conn, Map.merge(data, %{domain_name: domain_name})}

      _ ->
        {conn, data}
    end
  end

  defp put_server_domain_data({conn, data}), do: {conn, data}

  defp prepare_response(
         {%Plug.Conn{request_path: request_path} = conn, %{domain_name: domain_name}}
       ) do
    {
      put_resp_header(conn, "Location", make_redirect_path(domain_name, request_path)),
      302,
      ""
    }
  end

  defp prepare_response({%Plug.Conn{assigns: assigns, request_path: request_path} = conn, data}) do
    log_error(
      "Can't process request.\nConn assigns: #{inspect(assigns)}\nData: #{inspect(data)}\nRequest path: #{
        request_path
      }"
    )

    {conn, 404, "Server not found"}
  end

  defp make_redirect_path(domain_name, request_path) do
    ServerUtil.prepare_url(domain_name, 80, request_path)
  end
end
