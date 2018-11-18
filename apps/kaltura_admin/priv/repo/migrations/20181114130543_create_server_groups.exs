defmodule KalturaAdmin.Repo.Migrations.CreateServerGroups do
  use Ecto.Migration

  def change do
    create table(:server_groups) do
      add :name, :string
      add :description, :text
      add :status, :integer

      timestamps()
    end

    create table(:servers) do
      add :type, :integer
      add :domain_name, :string
      add :ip, :string
      add :port, :integer
      add :manage_ip, :string
      add :manage_port, :integer
      add :status, :integer
      add :weight, :integer
      add :prefix, :string
      add :healthcheck_enabled, :boolean, default: true, null: false
      add :healthcheck_path, :string

      timestamps()
    end
  end
end
