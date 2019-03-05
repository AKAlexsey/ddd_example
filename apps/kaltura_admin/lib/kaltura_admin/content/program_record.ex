defmodule KalturaAdmin.Content.ProgramRecord do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Content.Program
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  alias KalturaAdmin.{RecordingStatus, StreamProtocol}
  alias KalturaAdmin.Servers.Server
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:status, :protocol, :path, :server_id, :program_id]
  @required_fields [:status, :protocol, :path, :server_id, :program_id]

  schema "program_records" do
    field(:path, :string)
    field(:status, RecordingStatus)
    field(:protocol, StreamProtocol)

    belongs_to(:server, Server)
    belongs_to(:program, Program)

    timestamps()
  end

  @doc false
  def changeset(program_record, attrs) do
    program_record
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_server_present()
    |> validate_program_present()
  end

  defp validate_server_present(changeset) do
    changeset
    |> assoc_constraint(:server)
  end

  defp validate_program_present(changeset) do
    changeset
    |> assoc_constraint(:program)
  end
end
