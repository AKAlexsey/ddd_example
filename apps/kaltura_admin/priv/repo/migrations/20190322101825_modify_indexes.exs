defmodule KalturaAdmin.Repo.Migrations.ModifyIndexes do
  use Ecto.Migration

  def change do
    drop_if_exists index(:servers, :domain_name)
    create_if_not_exists unique_index(:servers, [:domain_name, :type])
    create_if_not_exists unique_index(:subnets, :cidr)
  end
end
