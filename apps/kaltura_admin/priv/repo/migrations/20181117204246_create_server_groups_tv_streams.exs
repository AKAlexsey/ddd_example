defmodule KalturaAdmin.Repo.Migrations.CreateServerGroupsTvStream do
  use Ecto.Migration

  def change do
    create table(:server_groups_tv_streams) do
      add :server_group_id, references(:server_groups, on_delete: :nothing)
      add :tv_stream_id, references(:tv_streams, on_delete: :nothing)

      timestamps()
    end

    create index(:server_groups_tv_streams, [:server_group_id])
    create index(:server_groups_tv_streams, [:tv_stream_id])
  end
end
