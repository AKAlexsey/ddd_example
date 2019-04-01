defmodule CtiKaltura.Repo.Migrations.CreateTvStreamModels do
  use Ecto.Migration

  def change do
    create table(:linear_channels) do
      add :name, :string
      add :code_name, :string
      add :description, :text, null: true
      add :dvr_enabled, :boolean, default: false, null: false
      add :epg_id, :string
      add :server_group_id, references(:server_groups, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:linear_channels, [:name])
    create unique_index(:linear_channels, [:code_name])
    create unique_index(:linear_channels, [:epg_id])

    create table(:tv_streams) do
      add :stream_path, :string
      add :status, :string
      add :protocol, :string
      add :encryption, :string
      add :linear_channel_id, references(:linear_channels, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:tv_streams, [:stream_path])
  end
end
