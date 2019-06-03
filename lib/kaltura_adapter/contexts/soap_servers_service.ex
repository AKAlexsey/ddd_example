defmodule CtiKaltura.ProgramScheduling.SoapServersService do
  @moduledoc """
  Осуществляет поиск и подбор DVR и EDGE сервера, для SOAP запроса.
  """

  @dvr_server_type "DVR"
  @edge_server_type "EDGE"
  @active_server_status "ACTIVE"

  alias CtiKaltura.Content.{LinearChannel, ProgramRecord}
  alias CtiKaltura.{ClosestEdgeServerService, Repo}

  @doc """
  Принимает параметры запроса и возаращает список серверов, для данного LinearChannel, Записи или tuple, содержащего Linear
  """
  @spec query_servers(tuple | ProgramRecord.t() | LinearChannel.t()) ::
          {binary | nil, binary | nil}
  def query_servers({_, %LinearChannel{} = linear_channel, _}) do
    query_servers(linear_channel)
  end

  def query_servers(%ProgramRecord{} = program_record) do
    program_record
    |> Repo.preload(program: :linear_channel)
    |> Map.get(:program, %{})
    |> Map.get(:linear_channel, %{})
    |> query_servers()
  end

  def query_servers(%LinearChannel{} = linear_channel) do
    linear_channel
    |> Repo.preload(server_group: :servers)
    |> Map.get(:server_group)
    |> case do
      nil ->
        []

      server_group ->
        server_group
        |> Map.get(:servers, [])
        |> Enum.reduce([], fn %{status: status} = el, acc ->
          if(status == @active_server_status, do: acc ++ [el], else: acc)
        end)
    end
  end

  def query_servers(_), do: {:error, :unknown_params_for_getting_dvr_server}

  @doc """
  Принимает параметры SOAP запроса и возвращает случайный DVR сервер группы LinearChannel.
  """
  @spec dvr_server_domain(any) :: nil | binary
  def dvr_server_domain(params) do
    params
    |> query_servers()
    |> select_all_servers_by_type(@dvr_server_type)
    |> select_dvr_server()
    |> case do
      nil ->
        nil

      %{manage_ip: manage_ip, manage_port: manage_port} ->
        "http://#{manage_ip}:#{manage_port}/cti-dvr/dvr-service"
    end
  end

  defp select_dvr_server([]), do: nil
  defp select_dvr_server(servers), do: Enum.random(servers)

  @doc """
  Принимает параметры SOAP запроса и возвращает случайный EDGE сервер группы LinearChannel с учётом его веса.
  """
  @spec edge_server_domain(any) :: nil | binary
  def edge_server_domain(params) do
    params
    |> query_servers()
    |> select_all_servers_by_type(@edge_server_type)
    |> select_edge_server()
    |> case do
      nil -> nil
      %{domain_name: domain_name} -> "http:\/\/#{domain_name}"
    end
  end

  defp select_edge_server([]), do: nil

  defp select_edge_server(servers) do
    random_number = :rand.uniform(ClosestEdgeServerService.sum_weights(servers))
    ClosestEdgeServerService.choose_server(servers, random_number)
  end

  defp select_all_servers_by_type(collection, type) when is_list(collection) do
    collection
    |> Enum.reduce([], fn %{type: server_type} = el, acc ->
      if(server_type == type, do: acc ++ [el], else: acc)
    end)
  end

  defp select_all_servers_by_type(_collection, _type), do: []
end
