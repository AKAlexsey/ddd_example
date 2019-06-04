defmodule CtiKaltura.Repo.Migrations.AlterServerAddFieldAvailability do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :availability, :boolean, default: true, null: false
    end
  end
end
