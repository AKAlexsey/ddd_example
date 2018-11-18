defmodule KalturaAdmin.TvStreamView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Servers

  def server_groups do
    Servers.list_server_groups()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_server_groups(nil), do: []

  def selected_server_groups(id) do
    Servers.server_group_ids_for_tv_stream(id)
  end

  def decorate_server_groups(server_groups) do
    server_groups
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")
  end
end
