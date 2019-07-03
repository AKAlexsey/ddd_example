defmodule CtiKaltura.RequestProcessing.DataReader do
  @moduledoc """
  Read data from the request and pass it to `assigns` attribute of the Plug connection.
  """

  use CtiKaltura.KalturaLogger, metadata: [domain: :request]

  import Plug.Conn

  @request_type_regex "(catchup|live)\/"
  @stream_meta "(hls|mpd)(_(wv|pr))?\/"
  @resource_regex "(\\w+)(.m3u8|.mpd)?$"
  @path_data_regex Regex.compile!("#{@request_type_regex}#{@stream_meta}#{@resource_regex}")
  @external_address_ip_header "x-real-ip"

  def init(options) do
    options
  end

  def call(%Plug.Conn{} = conn, _opts) do
    conn
    |> assign_request_data()
    |> add_ip_address()
  end

  defp assign_request_data(%Plug.Conn{request_path: "/btv/" <> rest_path} = conn) do
    case Regex.run(@path_data_regex, rest_path) do
      [_whole_path, _type, protocol, _dirty_encryption, encryption, resource_id | _] ->
        conn
        |> assign(:protocol, protocol)
        |> assign(:encryption, encryption)
        |> assign(:resource_id, resource_id)

      _result ->
        conn
    end
  end

  defp assign_request_data(%Plug.Conn{request_path: "/vod/" <> vod_path} = conn) do
    conn
    |> assign(:vod_path, vod_path)
  end

  defp assign_request_data(%Plug.Conn{request_path: "/static/" <> _} = conn) do
    conn
  end

  defp assign_request_data(%Plug.Conn{request_path: request_path} = conn) do
    log_debug("Wrong request path #{request_path}")
    conn
  end

  defp add_ip_address(%Plug.Conn{remote_ip: ip_address, req_headers: req_readers} = conn) do
    case ip_address_from_headers(req_readers) do
      nil ->
        assign(conn, :ip_address, ip_address)

      ip_address_from_headers ->
        assign(conn, :ip_address, ip_address_from_headers)
    end
  end

  defp ip_address_from_headers(headers_list) do
    headers_list
    |> Enum.reduce_while(nil, fn {header_name, ip}, acc ->
      case header_name do
        @external_address_ip_header ->
          {:halt, to_tuple_ip(ip)}

        _ ->
          {:cont, acc}
      end
    end)
  end

  defp to_tuple_ip(ip) do
    ip
    |> String.split(".")
    |> Enum.map(fn segment ->
      {seg, ""} = Integer.parse(segment)
      seg
    end)
    |> (fn [pt1, pt2, pt3, pt4] -> {pt1, pt2, pt3, pt4} end).()
  end
end
