defmodule CtiKaltura.Repo.Migrations.AddStorageIdToLinearChannel do
  use Ecto.Migration

  def change do
    alter(table(:linear_channels)) do
      add(:storage_id, :integer, allow_nil: true)
    end
  end
end
