defmodule KalturaAdmin.Repo.Migrations.AlterProgramRecordProtocolToString do
  use Ecto.Migration

  def change do
    add_protocol_new()
    update_protocol_new()
    remove_protocol()
    rename_protocol_new_to_protocol()
  end

  defp add_protocol_new do
    alter table(:program_records) do
      add :protocol_new, :string
    end
  end

  defp update_protocol_new do
    execute "UPDATE program_records SET protocol_new = 'HLS', encryption = 'NONE' WHERE protocol = 0"
    execute "UPDATE program_records SET protocol_new = 'MPD', encryption = 'NONE' WHERE protocol = 1"
    execute "UPDATE program_records SET protocol_new = 'MPD', encryption = 'WIDEVINE' WHERE protocol = 2"
    execute "UPDATE program_records SET protocol_new = 'MPD', encryption = 'PLAYREADY' WHERE protocol = 3"
  end

  defp remove_protocol do
    alter table(:program_records) do
      remove :protocol
    end
  end

  defp rename_protocol_new_to_protocol do
    rename table(:program_records), :protocol_new, to: :protocol
  end
end
