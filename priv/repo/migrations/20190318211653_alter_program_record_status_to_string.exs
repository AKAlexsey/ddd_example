defmodule CtiKaltura.Repo.Migrations.AlterProgramRecordStatusToString do
  use Ecto.Migration

  def change do
    add_status_new()
    update_status_new()
    remove_status()
    rename_status_new_to_status()
  end

  defp add_status_new do
    alter table(:program_records) do
      add :status_new, :string
    end
  end

  defp update_status_new do
    execute "UPDATE program_records SET status_new = 'PLANNED' WHERE status = 0"
    execute "UPDATE program_records SET status_new = 'RUNNING' WHERE status = 1"
    execute "UPDATE program_records SET status_new = 'COMPLETED' WHERE status = 2"
    execute "UPDATE program_records SET status_new = 'ERROR' WHERE status = 3"
  end

  defp remove_status do
    alter table(:program_records) do
      remove :status
    end
  end

  defp rename_status_new_to_status do
    rename table(:program_records), :status_new, to: :status
  end
end
