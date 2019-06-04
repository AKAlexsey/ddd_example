defmodule CtiKaltura.Util.ServerUtil do
  @moduledoc """
  A few util functions for Server entity and URL normalization
  """

  @doc """
  The method prepares full URL for particular server for further
  healthcheck process.
  """
  @spec prepare_url_for_healthcheck(Server.t()) :: String.t()
  def prepare_url_for_healthcheck(server) do
    prepare_url(server.domain_name, server.port, server.healthcheck_path)
  end

  @doc """
  The method prepares full URL for particular stream on given server.
  """
  @spec prepare_url_for_stream(Server.t(), String.t()) :: String.t()
  def prepare_url_for_stream(server, path) do
    prepare_url(server.domain_name, server.port, path)
  end

  @doc """
  The method prepares full URL for particular stream by
  host, port and path
  """
  @spec prepare_url(String.t(), number, String.t()) :: String.t()
  def prepare_url(host, port, path) do
    "#{prepare_protocol(port)}://#{prepare_host_port(host, port)}#{normalize_path(path)}"
  end

  @doc """
  The method normalizes path. The normalized path looks like:
  /some/path/playlist.m3u8
  It replaces double slashes and adds slash on the string's start if need
  """
  @spec normalize_path(String.t()) :: String.t()
  def normalize_path(path) do
    path
    |> remove_unnecessary_slashes()
    |> add_slash_at_start_if_needed()
  end

  defp remove_unnecessary_slashes(path) do
    if String.contains?(path, "//") do
      path |> String.replace("//", "/") |> remove_unnecessary_slashes()
    else
      path
    end
  end

  defp add_slash_at_start_if_needed(path) do
    if String.starts_with?(path, "/") do
      path
    else
      "/#{path}"
    end
  end

  defp prepare_protocol(443) do
    "https"
  end

  defp prepare_protocol(_) do
    "http"
  end

  defp prepare_host_port(host, 80) do
    host
  end

  defp prepare_host_port(host, 443) do
    host
  end

  defp prepare_host_port(host, port) do
    "#{host}:#{port}"
  end
end
