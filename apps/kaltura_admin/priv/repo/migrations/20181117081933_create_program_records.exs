defmodule KalturaAdmin.Repo.Migrations.CreateProgramRecords do
  use Ecto.Migration

  def change do
    create table(:program_records) do
      add :status, :integer
      add :protocol, :integer
      add :path, :string
      add :program_id, references(:programs, on_delete: :nothing)
      add :server_id, references(:servers, on_delete: :nothing)

      timestamps()
    end

    create index(:program_records, [:program_id])
    create index(:program_records, [:server_id])
  end
end
