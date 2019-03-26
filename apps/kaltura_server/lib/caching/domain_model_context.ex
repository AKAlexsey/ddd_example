defmodule KalturaServer.DomainModelContext do
  @moduledoc """
  Contains functions for searching cached data
  """

  require Amnesia
  require Amnesia.Helper

  @doc """
  Looking for TvStream by id and protocol using complex search index.
  """
  @spec find_tv_streams(binary, binary) :: map() | nil
  def find_tv_streams(epg_id, protocol) do
    :mnesia.dirty_index_match_object(
      DomainModel.TvStream,
      {DomainModel.TvStream, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6",
       {epg_id, "ACTIVE", String.upcase(protocol)}},
      8
    )
    |> make_domain_model_table_records()
  end

  @doc """
  Find ProgramRecord by epg_id, protocol, encryption.
  """
  @spec find_program_records(binary, binary) :: map() | nil
  def find_program_records(epg_id, protocol) do
    :mnesia.dirty_index_match_object(
      DomainModel.ProgramRecord,
      {DomainModel.ProgramRecord, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8",
       {epg_id, "COMPLETED", String.upcase(protocol)}},
      10
    )
    |> make_domain_model_table_records()
  end

  @doc """
  Iterate through all subnets and choose all those matches given IP address.
  """
  @spec get_subnets_for_ip(tuple) :: map() | []
  def get_subnets_for_ip(ip_address) do
    number_ip = CIDR.tuple2number(ip_address, 0)

    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Subnet, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8"},
          [
            make_and_mnesia_clause([
              {:"=<", :"$5", number_ip},
              {:>=, :"$6", number_ip}
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> Enum.sort_by(fn [_, _, _, _, parsed_cidr, _, _, _, _] -> -1 * parsed_cidr.mask end)
    |> make_domain_model_table_records()
  end

  @doc """
  Request from the mensia servers with given IDs and:
  * type == "EDGE";
  * status == "ACTIVE";
  * healthcheck_enabled == true.
  """
  @spec get_appropriate_servers(list(integer)) :: list(map())
  def get_appropriate_servers(server_ids) do
    Amnesia.transaction(fn ->
      :mnesia.select(DomainModel.Server, [
        {
          {:"$0", :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10", :"$12",
           :"$13"},
          [
            make_and_mnesia_clause([
              {:==, :"$2", "EDGE"},
              {:==, :"$6", "ACTIVE"},
              {:==, :"$9", true},
              make_in_mnesia_clause(server_ids, :"$1")
            ])
          ],
          [:"$$"]
        }
      ])
    end)
    |> make_domain_model_table_records()
  end

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
  def make_domain_model_table_record(nil), do: nil

  def make_domain_model_table_record(attrs) when is_list(attrs) do
    attrs
    |> List.to_tuple()
    |> make_domain_model_table_record()
  end

  def make_domain_model_table_record(attrs) when is_tuple(attrs) do
    attrs
    |> DomainModel.make_table_record()
  end

  def make_domain_model_table_records(records) when is_list(records) do
    records
    |> Enum.map(fn record -> make_domain_model_table_record(record) end)
  end
end
