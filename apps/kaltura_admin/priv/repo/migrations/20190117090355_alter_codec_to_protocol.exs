defmodule KalturaAdmin.Repo.Migrations.AlterCodecToProtocol do
  use Ecto.Migration

  def up do
    alter(table(:tv_streams)) do
      add(:protocol, :integer)
    end

    execute("UPDATE tv_streams SET protocol = 0")

    rename(table(:program_records), :codec, to: :protocol)
  end

  def down do
    alter(table(:tv_streams)) do
      remove(:protocol)
    end

    rename(table(:program_records), :protocol, to: :codec)
  end
end
