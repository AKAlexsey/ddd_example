defmodule KalturaAdmin.Servers.ServerGroupsTvStream do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Content.TvStream
  alias KalturaAdmin.Servers.ServerGroup

  @cast_fields [:server_group_id, :tv_stream_id]
  @required_fields [:server_group_id, :tv_stream_id]

  schema "server_groups_tv_streams" do
    belongs_to(:server_group, ServerGroup, on_replace: :delete)
    belongs_to(:tv_stream, TvStream, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(server_groups_tv_streams, attrs) do
    server_groups_tv_streams
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:server_group)
    |> assoc_constraint(:tv_stream)
  end

  def server_group_changeset(server_groups_tv_streams, attrs) do
    server_groups_tv_streams
    |> cast(attrs, [:tv_stream_id])
    |> validate_required([:tv_stream_id])
    |> assoc_constraint(:tv_stream)
  end

  def tv_stream_changeset(server_groups_tv_streams, attrs) do
    server_groups_tv_streams
    |> cast(attrs, [:server_group_id])
    |> validate_required([:server_group_id])
    |> assoc_constraint(:server_group)
  end
end
