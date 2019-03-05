defmodule KalturaAdmin.Servers.ServerGroup do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.{ActiveStatus, Repo, Servers}
  alias KalturaAdmin.Area.{Region, RegionServerGroup}
  alias KalturaAdmin.Content.LinearChannel
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  alias KalturaAdmin.Servers.{Server, ServerGroupServer}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [:name, :description, :status]
  @required_fields [:name, :status]

  schema "server_groups" do
    field(:description, :string)
    field(:name, :string)
    field(:status, ActiveStatus)

    has_many(
      :region_server_groups,
      RegionServerGroup,
      foreign_key: :server_group_id,
      on_replace: :delete
    )

    many_to_many(:regions, Region, join_through: RegionServerGroup)

    has_many(:linear_channels, LinearChannel, foreign_key: :server_group_id)

    has_many(
      :server_group_servers,
      ServerGroupServer,
      foreign_key: :server_group_id,
      on_replace: :delete
    )

    many_to_many(:servers, Server, join_through: ServerGroupServer)

    timestamps()
  end

  @doc false
  def changeset(%{id: id} = server_group, attrs) do
    server_group
    |> Repo.preload(:region_server_groups)
    |> Repo.preload(:linear_channels)
    |> Repo.preload(:server_group_servers)
    |> cast_regions(id, attrs)
    |> cast_servers(id, attrs)
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> unique_constraint(:name)
  end

  defp cast_regions(changeset, id, %{region_ids: reg_ids}) do
    perform_casting_server_groups(changeset, id, reg_ids)
  end

  defp cast_regions(changeset, id, %{"region_ids" => reg_ids}) do
    perform_casting_server_groups(changeset, id, reg_ids)
  end

  defp cast_regions(changeset, _id, _attrs), do: changeset

  defp perform_casting_server_groups(changeset, id, reg_ids) do
    changeset
    |> cast(%{region_server_groups: Servers.make_request_region_params(id, reg_ids)}, [])
    |> cast_assoc(
      :region_server_groups,
      with: &RegionServerGroup.server_group_association_changeset/2
    )
  end

  defp cast_servers(changeset, id, %{server_ids: ids}) do
    perform_casting_servers(changeset, id, ids)
  end

  defp cast_servers(changeset, id, %{"server_ids" => ids}) do
    perform_casting_servers(changeset, id, ids)
  end

  defp cast_servers(changeset, _id, _attrs), do: changeset

  defp perform_casting_servers(changeset, id, ids) do
    changeset
    |> cast(%{server_group_servers: Servers.make_request_server_params(id, ids)}, [])
    |> cast_assoc(:server_group_servers, with: &ServerGroupServer.server_group_changeset/2)
  end
end
