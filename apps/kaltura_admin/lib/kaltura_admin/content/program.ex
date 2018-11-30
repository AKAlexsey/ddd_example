defmodule KalturaAdmin.Content.Program do
  use Ecto.Schema
  import Ecto.Changeset

  alias KalturaAdmin.Content.TvStream
  alias KalturaAdmin.Observers.{DomainModelObserver, DomainModelNotifier}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:name, :start_datetime, :end_datetime, :epg_id]
  @required_fields [:name, :start_datetime, :end_datetime, :epg_id]

  schema "programs" do
    field(:name, :string)
    field(:start_datetime, :naive_datetime)
    field(:end_datetime, :naive_datetime)
    field(:epg_id, :string)

    belongs_to(:tv_stream, TvStream)

    timestamps()
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
