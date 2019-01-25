defmodule KalturaAdmin.Servers.ServerGroupServer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.Servers.{Server, ServerGroup}

  @cast_fields [:server_group_id, :server_id]
  @required_fields [:server_group_id, :server_id]

  schema "server_group_servers" do
    belongs_to(:server_group, ServerGroup, on_replace: :delete)
    belongs_to(:server, Server, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(server_group_server, attrs) do
    server_group_server
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:server_group)
    |> assoc_constraint(:server)
  end

  def server_group_changeset(server_group_server, attrs) do
    server_group_server
    |> cast(attrs, [:server_id])
    |> validate_required([:server_id])
    |> assoc_constraint(:server)
  end

  def server_changeset(server_group_server, attrs) do
    server_group_server
    |> cast(attrs, [:server_group_id])
    |> validate_required([:server_group_id])
    |> assoc_constraint(:server_group)
  end
end
