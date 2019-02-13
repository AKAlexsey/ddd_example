defmodule KalturaServer.DomainModelContext do
  @moduledoc """
  Contains functions for searching cached data
  """

  require Amnesia
  require Amnesia.Helper

  @doc """
  Looking for tv_stream by epg_id. If there is no such stream return nil.
  """
  @spec find_tv_stream(binary, atom | binary) :: map() | nil
  def find_tv_stream(epg_id, protocol \\ nil) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.TvStream, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9"},
          [
            make_and_mnesia_clause([
              {:==, :"$2", epg_id},
              {:==, :"$5", normalize_protocol(protocol)}
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> get_transaction_result_value()
    |> make_domain_model_table_result()
  end

  defp normalize_protocol(protocol) when is_atom(protocol) do
    protocol
    |> to_string()
    |> normalize_protocol()
  end

  defp normalize_protocol(protocol) do
    protocol
    |> String.upcase()
    |> String.to_atom()
  end

  @doc """
  Find Program by epg_id or return nil.
  """
  @spec find_program(binary) :: map() | nil
  def find_program(epg_id) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Program, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5"},
          [{:==, :"$4", epg_id}],
          [:"$$"]
        }
      ])
    end)
    |> get_transaction_result_value()
    |> make_domain_model_table_result()
  end

  @doc """
  Find ProgramRecord by program_id and protocol or return nil.
  """
  @spec find_program_record(integer, atom) :: map() | nil
  def find_program_record(program_id, protocol) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.ProgramRecord, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6"},
          [
            make_and_mnesia_clause([
              {:==, :"$2", program_id},
              {:==, :"$5", normalize_protocol(protocol)}
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> get_transaction_result_value()
    |> make_domain_model_table_result()
  end

  @doc """
  Find DVR Server by ID or return nil.
  """
  @spec find_dvr_server(integer) :: map() | nil
  def find_dvr_server(server_id) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Server, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$11",
           :"$12"},
          [
            make_and_mnesia_clause([
              {:==, :"$1", server_id},
              {:==, :"$2", :dvr},
              {:==, :"$6", :active}
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> get_transaction_result_value()
    |> make_domain_model_table_result()
  end

  @doc """
  Iterate through all subnets and choose all those matches given IP address.
  """
  @spec get_subnets_for_ip(binary) :: map() | []
  def get_subnets_for_ip(ip_address) do
    Amnesia.transaction(fn ->
      Amnesia.Table.foldl(DomainModel.Subnet, [], fn {_, _, _, _, parsed_cidr, _} = subnet, acc ->
        concat_subnet_if_it_matches(parsed_cidr, ip_address, acc, subnet)
      end)
    end)
    |> Enum.sort_by(fn {_, _, _, _, parsed_cidr, _} -> -1 * parsed_cidr.mask end)
    |> Enum.map(fn attrs -> DomainModel.make_table_record(attrs) end)
  end

  defp concat_subnet_if_it_matches(parsed_cidr, ip_address, acc, subnet) do
    if(CIDR.match!(parsed_cidr, ip_address), do: acc ++ [subnet], else: acc)
  end

  @doc """
  Get subnet region
  """
  @spec get_subnet_region(map()) :: map() | nil
  def get_subnet_region(%{region_id: region_id}) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Region, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5"},
          [{:==, :"$1", region_id}],
          [:"$$"]
        }
      ])
    end)
    |> get_transaction_result_value()
    |> make_domain_model_table_result()
  end

  @doc """
  Get all region servers through server groups
  """
  @spec get_appropriate_server_group_ids(map() | nil, integer) :: list(integer) | []
  def get_appropriate_server_group_ids(%{server_group_ids: server_group_ids}, tv_stream_id) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.ServerGroup, [
        {
          {:_, :"$1", :_, :_, :"$4", :_, :"$6"},
          [make_in_mnesia_clause(server_group_ids, :"$1")],
          [{{:"$4", :"$6"}}]
        }
      ])
      |> Enum.filter(fn {_server_ids, tv_stream_ids} -> tv_stream_id in tv_stream_ids end)
      |> Enum.map(fn {server_ids, _tv_stream_ids} -> server_ids end)
      |> List.flatten()
      |> Enum.uniq()
    end)
  end

  def get_appropriate_server_group_ids(nil, _tv_stream_id), do: []

  @doc """
  Get region server groups
  """
  @spec get_region_server_ids(map() | nil) :: list(integer) | []
  def get_region_server_ids(%{server_group_ids: server_group_ids}) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.ServerGroup, [
        {
          {:_, :"$1", :_, :_, :"$4", :_, :"$6"},
          [make_in_mnesia_clause(server_group_ids, :"$1")],
          [:"$4"]
        }
      ])
      |> List.flatten()
      |> Enum.uniq()
    end)
  end

  def get_region_server_ids(nil), do: []

  @doc """
  Request from the mensia servers with given IDs and:
  * type == :edge;
  * status == :active;
  * healthcheck_enabled == true.
  """
  @spec get_appropriate_servers(list(integer)) :: list(map())
  def get_appropriate_servers(server_ids) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Server, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$11",
           :"$12"},
          [
            make_and_mnesia_clause([
              {:==, :"$2", :edge},
              {:==, :"$6", :active},
              {:==, :"$9", true},
              make_in_mnesia_clause(server_ids, :"$1")
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> Enum.map(&make_domain_model_table_result(&1))
  end

  defp get_transaction_result_value([head | _tail]), do: head
  defp get_transaction_result_value([]), do: nil

  @doc """
  Gets ids list and variable name. And return IN clause for mnesia query.

  Examples:
  * DomainModelContext.make_in_mnesia_clause([], :"$1") #=> nil
  * DomainModelContext.make_in_mnesia_clause([1], :"$1") #=> {:==, name, 1}
  * DomainModelContext.make_in_mnesia_clause([1, 2], :"$1") #=> {:orelse, {:==, :"$1", 2}, {:==, :"$1", 1}}
  * DomainModelContext.make_in_mnesia_clause([1, 2, 3], :"$1") #=> {:orelse, {:==, :"$1", 3}, {:orelse, {:==, :"$1", 2}, {:==, :"$1", 1}}}
  """
  @spec make_in_mnesia_clause(list(integer), any) :: tuple
  def make_in_mnesia_clause(values_list, variable_name) when is_list(values_list) do
    Enum.reduce(values_list, nil, fn
      value, nil ->
        {:==, variable_name, value}

      value, clause ->
        {:orelse, {:==, variable_name, value}, clause}
    end)
  end

  @doc """
  Glues clauses into list of AND clauses for Mnesia clause.

  Examples:
  * DomainModelContext.make_and_mnesia_clause([]) #=> nil
  * DomainModelContext.make_and_mnesia_clause([{:==, :"$1", 1}]) #=> {:==, :"$1", 1}
  * DomainModelContext.make_and_mnesia_clause([{:==, :"$1", 1}, {:==, :"$2", 2}]) #=> {:andalso, {:==, :"$1", 1}, {:==, :"$2", 2}}
  * DomainModelContext.make_and_mnesia_clause([{:==, :"$1", 1}, {:==, :"$2", 2}, {:==, :"$3", 3}]) #=> {:andalso, {:andalso, {:==, :"$1", 1}, {:==, :"$2", 2}}, {:==, :"$3", 3}}
  """
  @spec make_and_mnesia_clause(list(tuple)) :: tuple
  def make_and_mnesia_clause(clauses_list) when is_list(clauses_list) do
    Enum.reduce(clauses_list, nil, fn
      clause, nil ->
        clause

      clause, clauses ->
        {:andalso, clauses, clause}
    end)
  end

  @doc """
  Gets tuple and create new mnesia table record.
  """
  def make_domain_model_table_result(nil), do: nil

  def make_domain_model_table_result(attrs) when is_list(attrs) do
    attrs
    |> List.to_tuple()
    |> make_domain_model_table_result()
  end

  def make_domain_model_table_result(attrs) when is_tuple(attrs) do
    attrs
    |> DomainModel.make_table_record()
  end
end
