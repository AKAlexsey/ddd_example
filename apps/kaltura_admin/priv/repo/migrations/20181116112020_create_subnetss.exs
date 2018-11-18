defmodule KalturaAdmin.Repo.Migrations.CreateSubnetss do
  use Ecto.Migration

  def change do
    create table(:subnetss) do
      add :cidr, :string
      add :name, :string, null: true
      add :region_id, references(:regions, on_delete: :nothing)

      timestamps()
    end

    create index(:subnetss, [:region_id])
  end
end
