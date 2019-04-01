defmodule CtiKaltura.Repo.Migrations.CreateSubnets do
  use Ecto.Migration

  def change do
    create table(:subnets) do
      add :cidr, :string
      add :name, :string, null: true
      add :region_id, references(:regions, on_delete: :nothing)

      timestamps()
    end

    create index(:subnets, [:region_id])
  end
end
