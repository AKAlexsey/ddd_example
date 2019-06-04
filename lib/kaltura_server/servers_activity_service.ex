defmodule CtiKaltura.ServersActivityService do
  @moduledoc """
  Includes logic for servers activity checking functionality
  """
  use CtiKaltura.KalturaLogger, metadata: [domain: :servers_activity]

  alias CtiKaltura.DomainModelContext
  alias CtiKaltura.Servers
  alias CtiKaltura.Util.ServerUtil
  alias HTTPoison

  @doc """
  The method checks all servers on availability. The servers are from DB.
  Is analised ACTIVE servers only. Availability attribute saves in DB as boolean
  for every server.
  """
  @spec update_servers_activity :: {:ok, number}
  def update_servers_activity do
    servers = DomainModelContext.get_active_servers()

    servers
    |> Enum.each(fn server -> check_server_activity(server) end)

    {:ok, Enum.count(servers)}
  end

  @doc """
  The method checks availability for particular server.
  Availability attribute saves in DB as boolean
  """
  @spec check_server_activity(Server.t()) :: {:ok}
  def check_server_activity(server) do
    case get_server_activity(server) do
      {:error, reason} -> update_server_as_unavailable(server, reason)
      {:ok, status_code} -> update_server_as_available(server, status_code)
    end

    {:ok}
  end

  defp update_server_as_available(server, status_code) do
    if !server.availability do
      log_info(
        "Server #{server.domain_name} has come AVAILABLE again with HTTP-status #{status_code}"
      )

      loaded_server = Servers.get_server!(server.id, [:server_groups])

      loaded_server
      |> Servers.update_server(%{
        availability: true,
        server_group_ids: obtain_server_group_ids(loaded_server)
      })
    end
  end

  defp update_server_as_unavailable(server, reason) do
    if server.availability do
      log_error("Server #{server.domain_name} has come UNAVAILABLE! Reason: #{reason}")
      loaded_server = Servers.get_server!(server.id, [:server_groups])

      loaded_server
      |> Servers.update_server(%{
        availability: false,
        server_group_ids: obtain_server_group_ids(loaded_server)
      })
    end
  end

  defp obtain_server_group_ids(server) do
    server.server_groups |> Enum.map(fn group -> group.id end)
  end

  @doc """
  The method checks availability fro particular server
  and returns result.
  """
  @spec get_server_activity(Server.t()) :: {:ok, number} | {:error, String.t()}
  def get_server_activity(server) do
    url = ServerUtil.prepare_url_for_healthcheck(server)

    case HTTPoison.get(url, [], timeout: 2_000, recv_timeout: 2_000, hackney: [:insecure]) do
      {:error, %{:reason => reason}} ->
        {:error, reason}

      {:ok, %{:status_code => status_code, :body => body}} ->
        if status_code == 200 and body == "OK" do
          {:ok, status_code}
        else
          {:error, "HTTP-status is #{status_code}"}
        end
    end
  end
end
