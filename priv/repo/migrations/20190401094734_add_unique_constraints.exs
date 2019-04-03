defmodule KalturaAdmin.Repo.Migrations.AddUniqueConstraints do
  use Ecto.Migration

  def change do
    add_unique_constraint_for_users()
    add_unique_constraint_for_program_records()
  end

  defp add_unique_constraint_for_users do
    create unique_index(:users, [:email])
  end

  defp add_unique_constraint_for_program_records do
    create unique_index(:program_records, [:protocol, :encryption, :program_id])
  end
end
