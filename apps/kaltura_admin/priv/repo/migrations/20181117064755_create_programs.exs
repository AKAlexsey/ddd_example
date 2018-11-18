defmodule KalturaAdmin.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string
      add :start_datetime, :naive_datetime
      add :end_datetime, :naive_datetime
      add :epg_id, :string
      add :tv_stream_id, references(:tv_streams, on_delete: :nothing)

      timestamps()
    end

    create index(:programs, [:tv_stream_id])
  end
end
