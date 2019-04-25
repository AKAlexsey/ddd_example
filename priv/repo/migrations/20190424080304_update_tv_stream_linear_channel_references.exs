defmodule CtiKaltura.Repo.Migrations.UpdateTvStreamLinearChannelReferences do
  use Ecto.Migration

  def up do
    drop constraint("tv_streams", :tv_streams_linear_channel_id_fkey)
    alter table(:tv_streams) do
      modify :linear_channel_id, references(:linear_channels, on_delete: :restrict)
    end
  end

  def down do
    drop constraint("tv_streams", :tv_streams_linear_channel_id_fkey)
    alter table(:tv_streams) do
      modify :linear_channel_id, references(:linear_channels, on_delete: :delete_all)
    end
  end
end
