defmodule KalturaAdmin.ServerView do
  use KalturaAdminWeb, :view
  alias KalturaAdmin.Servers

  def server_groups do
    Servers.list_server_groups()
    |> Enum.map(fn %{name: name, id: id} -> {name, id} end)
  end

  def selected_server_groups(nil), do: []

  def selected_server_groups(server_id) do
    Servers.server_groups_ids_for_server(server_id)
  end

  def decorate_server_groups(server_groups) do
    server_groups
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")
  end
end
