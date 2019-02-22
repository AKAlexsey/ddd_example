defmodule KalturaServer.ClosestEdgeServerService do
  @moduledoc """
  Contains logic for finding closest edge server
  """

  alias KalturaServer.DomainModelContext, as: Context

  @spec perform(binary) :: map() | nil
  def perform(ip_address, opts \\ [])

  def perform(ip_address, linear_channel_id: linear_channel_id) do
    Context.get_subnets_for_ip(ip_address)
    |> Enum.reduce_while(nil, fn subnet, acc ->
      subnet
      |> Context.get_subnet_region()
      |> Context.get_appropriate_server_group_ids(linear_channel_id)
      |> Context.get_appropriate_servers()
      |> choose_random_server(acc)
    end)
  end

  def perform(ip_address, _opts) do
    Context.get_subnets_for_ip(ip_address)
    |> Enum.reduce_while(nil, fn subnet, acc ->
      subnet
      |> Context.get_subnet_region()
      |> Context.get_region_server_ids()
      |> Context.get_appropriate_servers()
      |> choose_random_server(acc)
    end)
  end

  defp choose_random_server([], acc), do: {:cont, acc}

  defp choose_random_server(servers, _acc) do
    random_number = :rand.uniform(sum_weights(servers))
    {:halt, choose_server(servers, random_number)}
  end

  @spec sum_weights(map()) :: integer
  def sum_weights(servers) do
    Enum.reduce(servers, 0, fn %{weight: weight}, acc -> weight + acc end)
  end

  @spec choose_server(list(), integer) :: map() | %{}
  def choose_server([], _random_number), do: %{}
  def choose_server(_servers, random_number) when random_number <= 0, do: %{}

  def choose_server(servers, random_number) do
    servers
    |> Enum.reduce_while(0, fn %{weight: weight} = server, starting_interval ->
      ending_interval = starting_interval + weight

      if random_number in (starting_interval + 1)..ending_interval do
        {:halt, server}
      else
        {:cont, ending_interval}
      end
    end)
  end
end
