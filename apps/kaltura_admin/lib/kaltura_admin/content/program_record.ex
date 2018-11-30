defmodule KalturaAdmin.Content.ProgramRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Content.Program
  alias KalturaAdmin.Observers.{DomainModelObserver, DomainModelNotifier}
  alias KalturaAdmin.Servers.Server
  alias KalturaAdmin.{RecordingStatus, RecordCodec}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:status, :codec, :path, :server_id, :program_id]
  @required_fields [:status, :codec, :path, :server_id, :program_id]

  schema "program_records" do
    field(:path, :string)
    field(:status, RecordingStatus)
    field(:codec, RecordCodec)

    belongs_to(:server, Server)
    belongs_to(:program, Program)

    timestamps()
  end

  @doc false
  def changeset(program_record, attrs) do
    program_record
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
