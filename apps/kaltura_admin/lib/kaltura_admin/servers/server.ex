defmodule KalturaAdmin.Servers.Server do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.{ActiveStatus, Repo, Servers, ServerType}
  alias KalturaAdmin.Content.ProgramRecord
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  alias KalturaAdmin.Servers.{ServerGroup, ServerGroupServer}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [
    :type,
    :domain_name,
    :ip,
    :port,
    :manage_ip,
    :manage_port,
    :status,
    :weight,
    :prefix,
    :healthcheck_enabled,
    :healthcheck_path
  ]
  @required_fields [:type, :domain_name, :ip, :port, :status, :weight, :prefix]

  schema "servers" do
    field(:domain_name, :string)
    field(:healthcheck_enabled, :boolean, default: true)
    field(:healthcheck_path, :string)
    field(:ip, :string)
    field(:manage_ip, :string)
    field(:manage_port, :integer)
    field(:port, :integer)
    field(:prefix, :string)
    field(:status, ActiveStatus)
    field(:type, ServerType)
    field(:weight, :integer)

    has_many(
      :server_group_servers,
      ServerGroupServer,
      foreign_key: :server_id,
      on_replace: :delete
    )

    many_to_many(:server_groups, ServerGroup, join_through: ServerGroupServer)

    has_many(:program_records, ProgramRecord, foreign_key: :server_id)

    timestamps()
  end

  @doc false
  def changeset(%{id: id} = server, attrs) do
    server
    |> Repo.preload(:server_group_servers)
    |> cast_server_groups(id, attrs)
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  defp cast_server_groups(changeset, id, %{server_group_ids: ids}) do
    perform_casting_server_groups(changeset, id, ids)
  end

  defp cast_server_groups(changeset, id, %{"server_group_ids" => ids}) do
    perform_casting_server_groups(changeset, id, ids)
  end

  defp cast_server_groups(changeset, _id, _attrs), do: changeset

  defp perform_casting_server_groups(changeset, id, ids) do
    changeset
    |> cast(
      %{server_group_servers: Servers.make_request_server_group_for_server_params(id, ids)},
      []
    )
    |> cast_assoc(:server_group_servers, with: &ServerGroupServer.server_changeset/2)
  end
end
