use Amnesia
alias CtiKaltura.NodesService

defdatabase DomainModel do
  deftable LinearChannel,
           [
             :id,
             :epg_id,
             :name,
             :code_name,
             :dvr_enabled,
             :server_group_id,
             :program_ids,
             :tv_stream_ids
           ],
           type: :ordered_set,
           copying: [memory: NodesService.get_nodes()] do
    @type t :: %LinearChannel{
            id: integer,
            epg_id: String.t(),
            name: String.t(),
            code_name: String.t(),
            dvr_enabled: boolean,
            server_group_id: integer,
            program_ids: list(integer),
            tv_stream_ids: list(integer)
          }
  end

  deftable Program, [:id, :name, :linear_channel_id, :epg_id, :program_record_ids],
    type: :ordered_set,
    copying: [memory: NodesService.get_nodes()] do
    @type t :: %Program{
            id: integer,
            name: String.t(),
            linear_channel_id: integer,
            epg_id: String.t(),
            program_record_ids: list(integer)
          }
  end

  deftable ProgramRecord,
           [
             :id,
             :program_id,
             :server_id,
             :status,
             :protocol,
             :path,
             :prefix,
             :encryption,
             :complex_search_index
           ],
           type: :ordered_set,
           copying: [memory: NodesService.get_nodes()] do
    @type t :: %ProgramRecord{
            id: integer,
            program_id: integer,
            server_id: integer,
            status: String.t(),
            protocol: String.t(),
            path: String.t(),
            prefix: String.t(),
            complex_search_index: tuple
          }
  end

  deftable Region, [:id, :name, :status, :subnet_ids, :server_group_ids],
    type: :ordered_set,
    copying: [memory: NodesService.get_nodes()] do
    @type t :: %Region{
            id: integer,
            name: String.t(),
            status: String.t(),
            subnet_ids: list(integer),
            server_group_ids: list(integer)
          }
  end

  deftable ServerGroup, [:id, :name, :status, :server_ids, :region_ids, :linear_channel_ids],
    type: :ordered_set,
    copying: [memory: NodesService.get_nodes()] do
    @type t :: %ServerGroup{
            id: integer,
            name: String.t(),
            status: String.t(),
            server_ids: list(integer),
            region_ids: list(integer),
            linear_channel_ids: list(integer)
          }
  end

  deftable Server,
           [
             :id,
             :type,
             :domain_name,
             :ip,
             :port,
             :status,
             :weight,
             :prefix,
             :healthcheck_enabled,
             :server_group_ids,
             :program_record_ids
           ],
           type: :ordered_set,
           copying: [memory: NodesService.get_nodes()] do
    @type t :: %Server{
            id: integer,
            type: String.t(),
            domain_name: String.t(),
            ip: String.t(),
            port: integer,
            status: String.t(),
            weight: integer,
            prefix: String.t(),
            healthcheck_enabled: true,
            server_group_ids: list(integer),
            program_record_ids: list(integer)
          }
  end

  deftable Subnet,
           [
             :id,
             :region_id,
             :cidr,
             :parsed_cidr,
             :first_number_ip,
             :last_number_ip,
             :name
           ],
           type: :ordered_set,
           copying: [memory: NodesService.get_nodes()] do
    @type t :: %Subnet{
            id: integer,
            region_id: integer,
            cidr: String.t(),
            parsed_cidr: any,
            first_number_ip: integer,
            last_number_ip: integer,
            name: String.t()
          }
  end

  deftable TvStream,
           [
             :id,
             :stream_path,
             :status,
             :protocol,
             :encryption,
             :linear_channel_id,
             :complex_search_index
           ],
           type: :ordered_set,
           copying: [memory: NodesService.get_nodes()] do
    @type t :: %TvStream{
            id: integer,
            stream_path: String.t(),
            status: String.t(),
            protocol: String.t(),
            encryption: String.t(),
            linear_channel_id: integer,
            complex_search_index: tuple
          }
  end

  def cidr_fields_for_search(cidr) do
    parsed_cidr = CIDR.parse(cidr)

    %{
      parsed_cidr: parsed_cidr,
      first_number_ip: CIDR.tuple2number(parsed_cidr.first, 0),
      last_number_ip: CIDR.tuple2number(parsed_cidr.last, 0)
    }
  end

  def add_indexes do
    Amnesia.Table.add_index(DomainModel.Program, :epg_id)
    Amnesia.Table.add_index(DomainModel.Subnet, :first_number_ip)
    Amnesia.Table.add_index(DomainModel.Subnet, :last_number_ip)
    Amnesia.Table.add_index(DomainModel.Server, :type)
    Amnesia.Table.add_index(DomainModel.Server, :status)
    Amnesia.Table.add_index(DomainModel.Server, :healthcheck_enabled)
    Amnesia.Table.add_index(DomainModel.LinearChannel, :epg_id)
    Amnesia.Table.add_index(DomainModel.TvStream, :complex_search_index)
    Amnesia.Table.add_index(DomainModel.ProgramRecord, :complex_search_index)
  end

  # TODO Probably there is some native way to make table struct from mnesia query result.
  # But i had not found it.
  def make_table_record(attrs) when is_tuple(attrs) do
    attrs
    |> Tuple.to_list()
    |> make_table_record()
  end

  def make_table_record(attrs) when is_list(attrs) do
    table = hd(attrs)
    values = Enum.slice(attrs, 1..-1)

    table.attributes()
    |> Keyword.keys()
    |> Enum.zip(values)
    |> Enum.into(%{})
    |> table.__struct__()
  end
end
