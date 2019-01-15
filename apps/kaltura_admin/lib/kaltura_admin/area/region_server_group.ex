defmodule KalturaAdmin.Area.RegionServerGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias KalturaAdmin.Area.Region
  alias KalturaAdmin.Servers.ServerGroup

  @cast_fields [:region_id, :server_group_id]
  @required_fields [:region_id, :server_group_id]

  schema "region_server_groups" do
    belongs_to(:region, Region, on_replace: :delete)
    belongs_to(:server_group, ServerGroup, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(region_server_group, attrs) do
    region_server_group
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:region)
    |> assoc_constraint(:server_group)
  end

  def region_association_changeset(region_server_group, attrs) do
    region_server_group
    |> cast(attrs, @cast_fields)
    |> validate_required([:server_group_id])
    |> assoc_constraint(:server_group)
  end

  def server_group_association_changeset(region_server_group, attrs) do
    region_server_group
    |> cast(attrs, @cast_fields)
    |> validate_required([:region_id])
    |> assoc_constraint(:region)
  end
end
