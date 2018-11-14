defmodule KalturaAdmin.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :url, :text

      timestamps()
    end
  end
end
