defmodule KalturaAdmin.Content.TvStream do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Content.LinearChannel
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  use DomainModelNotifier, observers: [DomainModelObserver]

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

  @doc false
  def changeset(tv_stream, attrs) do
    tv_stream
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_linear_channel_present()
    |> validate_stream_path_uniq()
  end

  defp validate_linear_channel_present(changeset) do
    changeset
    |> assoc_constraint(:linear_channel)
  end

  defp validate_stream_path_uniq(changeset) do
    changeset
    |> unique_constraint(:stream_path)
  end
end
