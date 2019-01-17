use Amnesia

defdatabase DomainModel do
  deftable TvStream,
           [
             :id,
             :epg_id,
             :stream_path,
             :status,
             :protocol,
             :name,
             :code_name,
             :server_group_ids,
             :program_ids
           ],
           type: :ordered_set do
    @type t :: %TvStream{
            id: integer,
            epg_id: String.t(),
            stream_path: String.t(),
            status: atom,
            protocol: atom,
            name: String.t(),
            code_name: String.t(),
            server_group_ids: list(integer),
            program_ids: list(integer)
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
             :streaming_server_group_ids,
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
            streaming_server_group_ids: list(integer),
            program_record_ids: list(integer)
          }
  end

  deftable Subnet, [:id, :region_id, :cidr, :name], type: :ordered_set do
    @type t :: %Subnet{id: integer, region_id: integer, cidr: String.t(), name: String.t()}
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

  deftable ServerGroup, [:id, :name, :status, :server_ids, :region_ids, :tv_stream_ids],
    type: :ordered_set do
    @type t :: %ServerGroup{
            id: integer,
            name: String.t(),
            status: atom,
            server_ids: list(integer),
            region_ids: list(integer),
            tv_stream_ids: list(integer)
          }
  end

  deftable Program, [:id, :name, :tv_stream_id, :epg_id, :program_record_ids], type: :ordered_set do
    @type t :: %Program{
            id: integer,
            name: String.t(),
            tv_stream_id: integer,
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
end
