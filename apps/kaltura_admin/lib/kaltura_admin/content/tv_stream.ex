defmodule KalturaAdmin.Content.TvStream do
  use Ecto.Schema
  import Ecto.Changeset
  alias KalturaAdmin.{ActiveStatus, Repo, Servers}
  alias KalturaAdmin.Servers.{ServerGroupsTvStream, ServerGroup}

  @cast_fields [:stream_path, :status, :name, :code_name, :description, :dvr_enabled, :epg_id]
  @required_fields [:stream_path, :status, :name, :code_name, :dvr_enabled, :epg_id]

  schema "tv_streams" do
    field(:code_name, :string)
    field(:description, :string, null: true)
    field(:dvr_enabled, :boolean, default: false)
    field(:epg_id, :string)
    field(:name, :string)
    field(:status, ActiveStatus)
    field(:stream_path, :string)

    has_many(
      :server_group_tv_streams,
      ServerGroupsTvStream,
      foreign_key: :tv_stream_id,
      on_replace: :delete
    )

    many_to_many(:server_groups, ServerGroup, join_through: ServerGroupsTvStream)

    timestamps()
  end

  @doc false
  def changeset(%{id: id} = tv_stream, attrs) do
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
