defmodule KalturaAdmin.Repo.Migrations.AlterProgramRecordAddEncryptionString do
  use Ecto.Migration

  def change do
    alter table(:program_records) do
      add :encryption, :string, null: false, default: "NONE"
    end
  end
end
