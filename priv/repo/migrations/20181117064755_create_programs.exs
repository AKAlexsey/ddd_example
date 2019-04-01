defmodule CtiKaltura.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string
      add :start_datetime, :naive_datetime
      add :end_datetime, :naive_datetime
      add :epg_id, :string
      add :linear_channel_id, references(:linear_channels, on_delete: :nothing)

      timestamps()
    end

    create index(:programs, [:linear_channel_id])
  end
end
