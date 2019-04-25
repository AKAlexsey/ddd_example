defmodule CtiKaltura.Content.ProgramRecord do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias CtiKaltura.Content.Program
  alias CtiKaltura.Observers.{CrudActionsLogger, DomainModelNotifier, DomainModelObserver}
  alias CtiKaltura.Servers.Server
  use DomainModelNotifier, observers: [CrudActionsLogger, DomainModelObserver]

  @cast_fields [:status, :protocol, :encryption, :path, :server_id, :program_id]
  @required_fields [:status, :protocol, :encryption, :path, :server_id, :program_id]

  schema "program_records" do
    field(:path, :string)
    field(:status, :string)
    field(:protocol, :string)
    field(:encryption, :string)
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
    |> validate_protocol_encryption_program_id_unique()
  end

  defp validate_server_present(changeset) do
    changeset
    |> assoc_constraint(:server)
  end

  defp validate_program_present(changeset) do
    changeset
    |> assoc_constraint(:program)
  end

  defp validate_protocol_encryption_program_id_unique(changeset) do
    changeset
    |> unique_constraint(
      :protocol,
      name: :program_records_protocol_encryption_program_id_index,
      message: "The pair 'protocol', 'encryption' must be unique"
    )
  end
end
