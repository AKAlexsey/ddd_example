defmodule KalturaAdmin.RegionView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.{Area, Servers}

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
end
