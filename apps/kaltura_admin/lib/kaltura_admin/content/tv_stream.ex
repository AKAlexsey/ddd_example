defmodule KalturaAdmin.Content.TvStream do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.{ActiveStatus, Repo, Servers, StreamProtocol}
  alias KalturaAdmin.Content.Program
  alias KalturaAdmin.Observers.{DomainModelNotifier, DomainModelObserver}
  alias KalturaAdmin.Servers.{ServerGroup, ServerGroupsTvStream}
  use DomainModelNotifier, observers: [DomainModelObserver]

  @cast_fields [
    :stream_path,
    :status,
    :protocol,
    :name,
    :code_name,
    :description,
    :dvr_enabled,
    :epg_id
  ]
  @required_fields [:stream_path, :status, :protocol, :name, :code_name, :dvr_enabled, :epg_id]

  @type t :: %__MODULE__{}

  schema "tv_streams" do
    field(:code_name, :string)
    field(:description, :string, null: true)
    field(:dvr_enabled, :boolean, default: false)
    field(:epg_id, :string)
    field(:name, :string)
    field(:status, ActiveStatus)
    field(:stream_path, :string)
    field(:protocol, StreamProtocol)

    has_many(
      :server_group_tv_streams,
      ServerGroupsTvStream,
      foreign_key: :tv_stream_id,
      on_replace: :delete
    )

    many_to_many(:server_groups, ServerGroup, join_through: ServerGroupsTvStream)

    has_many(:programs, Program, foreign_key: :tv_stream_id)
    timestamps()
  end

  @doc false
  def changeset(tv_stream, attrs) do
    tv_stream
    |> cast_server_groups(attrs)
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  defp cast_server_groups(changeset, %{server_group_ids: ids}) do
    perform_casting_server_groups(changeset, ids)
  end

  defp cast_server_groups(changeset, %{"server_group_ids" => ids}) do
    perform_casting_server_groups(changeset, ids)
  end

  defp cast_server_groups(changeset, _attrs), do: changeset

  defp perform_casting_server_groups(%{id: id} = changeset, ids) do
    changeset
    |> Repo.preload(:server_group_tv_streams)
    |> cast(%{server_group_tv_streams: Servers.make_request_server_group_params(id, ids)}, [])
    |> cast_assoc(:server_group_tv_streams, with: &ServerGroupsTvStream.tv_stream_changeset/2)
  end
end
