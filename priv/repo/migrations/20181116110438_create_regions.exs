defmodule CtiKaltura.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string
      add :description, :text, null: true
      add :status, :integer

      timestamps()
    end

  end
end
