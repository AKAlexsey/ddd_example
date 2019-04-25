defmodule CtiKaltura.Content.LinearChannel do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias CtiKaltura.Repo
  alias CtiKaltura.Content.{Program, TvStream}
  alias CtiKaltura.Observers.{CrudActionsLogger, DomainModelNotifier, DomainModelObserver}
  alias CtiKaltura.Servers.ServerGroup
  use DomainModelNotifier, observers: [CrudActionsLogger, DomainModelObserver]

  @cast_fields [
    :name,
    :code_name,
    :description,
    :dvr_enabled,
    :epg_id,
    :server_group_id
  ]
  @required_fields [:name, :code_name, :epg_id]

  @type t :: %__MODULE__{}

  schema "linear_channels" do
    field(:name, :string)
    field(:code_name, :string)
    field(:description, :string, null: true)
    field(:dvr_enabled, :boolean, default: false)
    field(:epg_id, :string, unique: true)

    belongs_to(:server_group, ServerGroup)

    has_many(:tv_streams, TvStream, foreign_key: :linear_channel_id)
    has_many(:programs, Program, foreign_key: :linear_channel_id)

    timestamps()
  end

  @doc false
  def changeset(tv_stream, attrs) do
    tv_stream
    |> Repo.preload(:tv_streams)
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
    |> unique_constraint(:code_name)
    |> unique_constraint(:epg_id)
    |> validate_server_group_id_if_necessary()
    |> cast_tv_streams(attrs)
  end

  def validate_server_group_id_if_necessary(%{changes: %{dvr_enabled: true}} = changeset) do
    changeset
    |> validate_required([:server_group_id])
  end

  def validate_server_group_id_if_necessary(changeset), do: changeset

  defp cast_tv_streams(changeset, %{tv_streams: tv_stream_attributes}) do
    perform_casting_tv_streams(changeset, tv_stream_attributes)
  end

  defp cast_tv_streams(changeset, %{"tv_streams" => tv_stream_attributes}) do
    perform_casting_tv_streams(changeset, tv_stream_attributes)
  end

  defp cast_tv_streams(changeset, _attrs), do: changeset

  # TODO Реализовать нормальную работу с вложенными данными. В частности:
  # - Удаление, если был передан пустой массив. Тоесть удаление не существующих значений.
  # - Валидацию на уникальность комбинации linear_channel_id, protocol, encryption.
  # - Изменение существующих значений. (А может просто пересоздание)
  defp perform_casting_tv_streams(changeset, _tv_stream_attributes) do
    changeset
    |> cast_assoc(:tv_streams, with: &TvStream.changeset/2)
  end
end
