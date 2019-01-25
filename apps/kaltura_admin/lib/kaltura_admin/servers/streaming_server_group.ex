defmodule KalturaAdmin.Servers.StreamingServerGroup do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Servers.{Server, ServerGroup}

  @cast_fields [:server_id, :server_group_id]
  @required_fields [:server_id, :server_group_id]

  schema "streaming_server_groups" do
    belongs_to(:server, Server, on_replace: :delete)
    belongs_to(:server_group, ServerGroup, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(streaming_server_groups, attrs) do
    streaming_server_groups
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:server)
    |> assoc_constraint(:server_group)
  end

  @doc false
  def server_changeset(streaming_server_groups, attrs) do
    streaming_server_groups
    |> cast(attrs, [:server_group_id])
    |> validate_required([:server_group_id])
    |> assoc_constraint(:server_group)
  end
end
