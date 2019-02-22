use Amnesia

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
           type: :ordered_set do
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

  deftable TvStream,
           [
             :id,
             :stream_path,
             :status,
             :protocol,
             :encryption,
             :linear_channel_id
           ],
           type: :ordered_set do
    @type t :: %TvStream{
            id: integer,
            stream_path: String.t(),
            status: String.t(),
            protocol: atom,
            encryption: atom,
            linear_channel_id: integer
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
           type: :ordered_set do
    @type t :: %Server{
            id: integer,
            type: atom,
            domain_name: String.t(),
            ip: String.t(),
            port: integer,
            status: atom,
            weight: integer,
            prefix: String.t(),
            healthcheck_enabled: true,
            server_group_ids: list(integer),
            program_record_ids: list(integer)
          }
  end

  deftable Subnet, [:id, :region_id, :cidr, :parsed_cidr, :name], type: :ordered_set do
    @type t :: %Subnet{
            id: integer,
            region_id: integer,
            cidr: String.t(),
            parsed_cidr: any,
            name: String.t()
          }
  end

  deftable Region, [:id, :name, :status, :subnet_ids, :server_group_ids], type: :ordered_set do
    @type t :: %Region{
            id: integer,
            name: String.t(),
            status: atom,
            subnet_ids: list(integer),
            server_group_ids: list(integer)
          }
  end

  deftable ServerGroup, [:id, :name, :status, :server_ids, :region_ids, :linear_channel_ids],
    type: :ordered_set do
    @type t :: %ServerGroup{
            id: integer,
            name: String.t(),
            status: atom,
            server_ids: list(integer),
            region_ids: list(integer),
            linear_channel_ids: list(integer)
          }
  end

  deftable Program, [:id, :name, :linear_channel_id, :epg_id, :program_record_ids],
    type: :ordered_set do
    @type t :: %Program{
            id: integer,
            name: String.t(),
            linear_channel_id: integer,
            epg_id: String.t(),
            program_record_ids: list(integer)
          }
  end

  deftable ProgramRecord, [:id, :program_id, :server_id, :status, :protocol, :path],
    type: :ordered_set do
    @type t :: %ProgramRecord{
            id: integer,
            program_id: integer,
            server_id: integer,
            status: atom,
            protocol: atom,
            path: String.t()
          }
  end

  # TODO Probably there is some native way to make table struct from mnesia query result.
  # But i had not found it.
  def make_table_record(attrs) do
    list_attrs = Tuple.to_list(attrs)
    table = hd(list_attrs)
    values = Enum.slice(list_attrs, 1..-1)

    table.attributes()
    |> Keyword.keys()
    |> Enum.zip(values)
    |> Enum.into(%{})
    |> table.__struct__()
  end
end
