defmodule KalturaAdmin.Repo.Migrations.CreateStreamingServerGroups do
  use Ecto.Migration

  def change do
    create table(:streaming_server_groups) do
      add :server_id, references(:servers, on_delete: :nothing)
      add :server_group_id, references(:server_groups, on_delete: :nothing)

      timestamps()
    end

    create index(:streaming_server_groups, [:server_id])
    create index(:streaming_server_groups, [:server_group_id])
  end
end
