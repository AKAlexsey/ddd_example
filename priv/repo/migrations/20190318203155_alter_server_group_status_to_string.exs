defmodule CtiKaltura.Repo.Migrations.AlterServerGroupStatusToString do
  use Ecto.Migration

  def change do
    add_status_new()
    update_status_new()
    remove_status()
    rename_status_new_to_status()
  end

  defp add_status_new do
    alter table(:server_groups) do
      add :status_new, :string
    end
  end

  defp update_status_new do
    execute "UPDATE server_groups SET status_new = 'ACTIVE' WHERE status = 0"
    execute "UPDATE server_groups SET status_new = 'INACTIVE' WHERE status = 1"
  end

  defp remove_status do
    alter table(:server_groups) do
      remove :status
    end
  end

  defp rename_status_new_to_status do
    rename table(:server_groups), :status_new, to: :status
  end
end
