defmodule CtiKaltura.Repo.Migrations.CreateRegionServerGroups do
  use Ecto.Migration

  def change do
    create table(:region_server_groups) do
      add :region_id, references(:regions, on_delete: :delete_all)
      add :server_group_id, references(:server_groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:region_server_groups, [:region_id])
    create index(:region_server_groups, [:server_group_id])
    create unique_index(:region_server_groups, [:region_id, :server_group_id])
  end
end
