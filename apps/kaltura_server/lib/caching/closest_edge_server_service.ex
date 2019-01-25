defmodule KalturaServer.ClosestEdgeServerService do
  @moduledoc """
  Contains logic for finding closest edge server
  """

  alias KalturaServer.DomainModelContext, as: Context

  def perform(ip_address, tv_stream_id) do
    Context.get_subnets_for_ip(ip_address)
    |> Enum.reduce_while(nil, fn subnet, acc ->
      subnet
      |> Context.get_subnet_region()
      |> Context.get_appropriate_server_group_ids(tv_stream_id)
      |> Context.get_appropriate_servers()
      |> case do
        [] -> {:cont, acc}
        servers -> {:halt, choose_best_server(servers)}
      end
    end)
  end

  defp choose_best_server(servers) do
    sorted_servers = Enum.sort_by(servers, fn %{weight: weight} -> -1 * weight end)
    max_weight = Enum.at(sorted_servers, 0).weight

    sorted_servers
    |> Enum.reduce_while([], fn %{weight: weight} = server, acc ->
      if(weight == max_weight, do: {:cont, acc ++ [server]}, else: {:halt, acc})
    end)
    |> Enum.random()
  end
end
