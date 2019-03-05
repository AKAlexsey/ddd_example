defmodule KalturaAdmin.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:servers, :domain_name)
    create unique_index(:servers, :prefix)
    create unique_index(:server_groups, :name)
    create unique_index(:regions, :name)
    create unique_index(:subnets, :name)
    create unique_index(:programs, :epg_id)
  end
end
