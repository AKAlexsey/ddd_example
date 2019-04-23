defmodule CtiKaltura.Repo.Migrations.UpdateSubnetRegionReferences do
  use Ecto.Migration

  def up do
    drop constraint("subnets", :subnets_region_id_fkey)
    alter table(:subnets) do
      modify :region_id, references(:regions, on_delete: :restrict)
    end
  end

  def down do
    drop constraint("subnets", :subnets_region_id_fkey)
    alter table(:subnets) do
      modify :region_id, references(:regions, on_delete: :nothing)
    end
  end
end
