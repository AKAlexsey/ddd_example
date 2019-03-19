defmodule KalturaAdmin.Repo.Migrations.AlterServerTypeToString do
  use Ecto.Migration

  def change do
    add_type_new()
    update_type_new()
    remove_type()
    rename_type_new_to_type()
  end

  defp add_type_new do
    alter table(:servers) do
      add :type_new, :string
    end
  end

  defp update_type_new do
    execute "UPDATE servers SET type_new = 'EDGE' WHERE type = 0"
    execute "UPDATE servers SET type_new = 'DVR' WHERE type = 1"
  end

  defp remove_type do
    alter table(:servers) do
      remove :type
    end
  end

  defp rename_type_new_to_type do
    rename table(:servers), :type_new, to: :type
  end

end
