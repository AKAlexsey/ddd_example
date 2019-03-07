defmodule KalturaAdmin.RegionView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.{Area, Repo, Servers}
  alias KalturaAdmin.Area.Subnet

  import Ecto.Query

  def server_groups do
    Servers.list_server_groups()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_server_groups(nil), do: []

  def selected_server_groups(id) do
    Area.server_group_ids_for_region(id)
  end

  def decorate_server_groups(server_groups) do
    server_groups
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")
  end

  def subnets(region) do
    region_id = region.id

    Repo.all(from(sbn in Subnet, where: sbn.region_id == ^region_id))
  end

  def meta(region_id \\ nil) do
    [
      %{
        :header => "Name",
        :type => :string,
        :field => :name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Status",
        :type => :status,
        :field => :status,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Server groups",
        :type => :multiselect,
        :field => :server_groups,
        :mode => [:table, :show, :edit, :create],
        :checkbox_name => "region[server_group_ids][]",
        :items => server_groups(),
        :item_name_eval_fn => fn item -> item.name end,
        :selected_item_ids => selected_server_groups(region_id)
      }
    ]
  end

  def subnet_meta do
    [
      %{
        :header => "CIDR",
        :type => :string,
        :field => :cidr,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Name",
        :type => :string,
        :field => :name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Hidden region_id",
        :type => :hidden,
        :field => :region_id,
        :mode => [:create]
      }
    ]
  end
end
