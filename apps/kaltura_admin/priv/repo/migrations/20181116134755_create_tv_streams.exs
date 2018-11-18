defmodule KalturaAdmin.Repo.Migrations.CreateTvStreams do
  use Ecto.Migration

  def change do
    create table(:tv_streams) do
      add :stream_path, :string
      add :status, :integer
      add :name, :string
      add :code_name, :string
      add :description, :text, null: true
      add :dvr_enabled, :boolean, default: false, null: false
      add :epg_id, :string

      timestamps()
    end

  end
end
