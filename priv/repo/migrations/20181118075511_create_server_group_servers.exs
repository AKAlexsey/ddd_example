defmodule CtiKaltura.Repo.Migrations.CreateServerGroupServers do
  use Ecto.Migration

  def change do
    create table(:server_group_servers) do
      add :server_group_id, references(:server_groups, on_delete: :nothing)
      add :server_id, references(:servers, on_delete: :nothing)

      timestamps()
    end

    create index(:server_group_servers, [:server_group_id])
    create index(:server_group_servers, [:server_id])
  end
end
