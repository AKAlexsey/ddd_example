defmodule CtiKaltura.Repo.Migrations.AlterUserAddRole do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, null: false, default: "MANAGER"
    end
  end
end
