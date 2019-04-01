defmodule CtiKaltura.Content.Program do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias CtiKaltura.Content.{LinearChannel, ProgramRecord}
  alias CtiKaltura.Observers.{DomainModelNotifier, DomainModelObserver}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:name, :start_datetime, :end_datetime, :epg_id, :linear_channel_id]
  @required_fields [:name, :start_datetime, :end_datetime, :epg_id, :linear_channel_id]

  schema "programs" do
    field(:name, :string)
    field(:start_datetime, :naive_datetime)
    field(:end_datetime, :naive_datetime)
    field(:epg_id, :string)

    belongs_to(:linear_channel, LinearChannel)

    has_many(:program_records, ProgramRecord, foreign_key: :program_id)

    timestamps()
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_epg_id()
    |> validate_linear_channel_present()
  end

  defp validate_epg_id(changeset) do
    changeset
    |> unique_constraint(:epg_id)
  end

  defp validate_linear_channel_present(changeset) do
    changeset
    |> assoc_constraint(:linear_channel)
  end
end
