defmodule KalturaAdmin.Content.TvStream do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Content.LinearChannel
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @statuses ["ACTIVE", "INACTIVE"]
  @protocols ["HLS", "MPD"]
  @encryption ["NONE", "COMMON", "WIDEVINE", "PLAYREADY"]

  @cast_fields [
    :stream_path,
    :status,
    :protocol,
    :encryption,
    :linear_channel_id
  ]
  @required_fields [
    :stream_path,
    :status,
    :protocol,
    :encryption
  ]

  @type t :: %__MODULE__{}

  schema "tv_streams" do
    field(:stream_path, :string)
    field(:status, :string)
    field(:protocol, :string)
    field(:encryption, :string)

    belongs_to(:linear_channel, LinearChannel)

    timestamps()
  end

  def statuses, do: @statuses
  def protocols, do: @protocols
  def encryption, do: @encryption

  @doc false
  def changeset(tv_stream, attrs) do
    tv_stream
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
