defmodule KalturaServer.RequestProcessing.DataReader do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> assign(:query, parse_query_string(conn))
    |> assign(:ip_address, get_client_ip_address(conn))
  end

  def parse_query_string(%Plug.Conn{query_string: query_string}) do
    URI.decode_query(query_string)
  end

  def get_client_ip_address(%Plug.Conn{remote_ip: ip}) do
    ip
    |> Tuple.to_list()
    |> Enum.map(& to_string(&1))
    |> Enum.join(".")
  end
end
