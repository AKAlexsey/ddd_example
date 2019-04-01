defmodule CtiKaltura.Servers.Server do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias CtiKaltura.Content.ProgramRecord
  alias CtiKaltura.{Repo, Servers}
  alias CtiKaltura.Observers.{DomainModelNotifier, DomainModelObserver}
  alias CtiKaltura.Servers.{ServerGroup, ServerGroupServer}
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

  @weight_range 1..100
  @port_permitted_values [80, 443]
  @manage_port_range 0..65_535
  @domain_name_format ~r/^[a-z\d\-\.]+\.[a-z\d\-\.]+$/
  @prefix_format ~r/^[\w\-]+$/
  @healthcheck_path_format ~r/^\/[\w\-\/]+$/
  @ip_format ~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}+$/

  schema "servers" do
    field(:domain_name, :string)
    field(:healthcheck_enabled, :boolean, default: true)
    field(:healthcheck_path, :string)
    field(:ip, :string)
    field(:manage_ip, :string)
    field(:manage_port, :integer)
    field(:port, :integer)
    field(:prefix, :string)
    field(:status, :string)
    field(:type, :string)
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
    |> validate_domain_name_type_uniq()
    |> validate_domain_name_format()
    |> validate_weight()
    |> validate_port()
    |> validate_manage_port()
    |> validate_prefix()
    |> validate_healthcheck_path()
    |> validate_ip()
    |> validate_manage_ip()
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

  def validate_domain_name_type_uniq(changeset) do
    changeset
    |> unique_constraint(:domain_name, name: :servers_domain_name_type_index)
  end

  def validate_domain_name_format(changeset) do
    changeset
    |> validate_format(:domain_name, @domain_name_format)
  end

  defp validate_weight(changeset) do
    changeset
    |> validate_inclusion(:weight, @weight_range)
  end

  defp validate_port(changeset) do
    with %{changes: %{port: port_value}} <- changeset,
         false <- port_value in @port_permitted_values do
      changeset
      |> add_error(:port, "Can be only in #{inspect(@port_permitted_values)}")
    else
      _ -> changeset
    end
  end

  defp validate_manage_port(changeset) do
    changeset
    |> validate_inclusion(:manage_port, @manage_port_range)
  end

  defp validate_prefix(changeset) do
    changeset
    |> unique_constraint(:prefix)
    |> validate_format(:prefix, @prefix_format)
  end

  defp validate_healthcheck_path(changeset) do
    changeset
    |> validate_format(:healthcheck_path, @healthcheck_path_format)
  end

  defp validate_ip(changeset) do
    changeset
    |> validate_format(:ip, @ip_format)
    |> validate_ip_address_range(:ip)
  end

  defp validate_manage_ip(changeset) do
    changeset
    |> validate_format(:manage_ip, @ip_format)
    |> validate_ip_address_range(:manage_ip)
  end

  defp validate_ip_address_range(%{changes: changes, errors: errors} = changeset, attribute) do
    with value when not is_nil(value) <- Map.get(changes, attribute, nil),
         nil <- Keyword.get(errors, attribute, nil),
         false <- ip_address_range_valid?(value) do
      changeset
      |> add_error(attribute, "Out of range")
    else
      _ -> changeset
    end
  end

  defp ip_address_range_valid?(ip_address) do
    ip_address
    |> String.split(".")
    |> Enum.map(fn ip ->
      {number, ""} = Integer.parse(ip)
      number
    end)
    |> Enum.all?(fn num -> num in 0..255 end)
  end
end
