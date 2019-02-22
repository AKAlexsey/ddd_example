defmodule KalturaAdmin.LinearChannelView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Servers

  def server_groups do
    Servers.list_server_groups()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def decorate_server_groups(server_groups) do
    server_groups
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")
  end

  def server_group_name(%{server_group: server_group}) when not is_nil(server_group) do
    server_group.name
  end

  def server_group_name(_), do: ""
end
