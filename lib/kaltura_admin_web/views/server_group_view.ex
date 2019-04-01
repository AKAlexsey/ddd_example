defmodule CtiKaltura.ServerGroupView do
  use CtiKalturaWeb, :view

  alias CtiKaltura.{Area, Content, Servers}

  def regions do
    Area.list_regions()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_regions(nil), do: []

  def selected_regions(server_group_id) do
    Area.region_ids_for_server_group(server_group_id)
  end

  def linear_channels do
    Content.list_linear_channels()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def selected_linear_channels(nil), do: []

  def selected_linear_channels(server_group_id) do
    Servers.linear_channel_ids_for_server_group(server_group_id)
  end

  def servers do
    Servers.list_servers()
    |> Enum.map(fn item -> {Servers.server_name(item), item.id} end)
  end

  def selected_servers(nil), do: []

  def selected_servers(server_group_id) do
    Servers.server_ids_for_server_group(server_group_id)
  end

  def decorate_collection(servers, name_field \\ :name) do
    servers
    |> Enum.map(fn %{^name_field => name} -> name end)
    |> Enum.join(", ")
  end

  def meta(serverGroup \\ nil) do
    server_group_id =
      if serverGroup == nil do
        nil
      else
        serverGroup.id
      end

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
        :header => "Regions",
        :type => :multiselect,
        :field => :regions,
        :mode => [:table, :show, :edit, :create],
        :checkbox_name => "server_group[region_ids][]",
        :items => regions(),
        :item_name_eval_fn => fn item -> item.name end,
        :selected_item_ids => selected_regions(server_group_id)
      },
      %{
        :header => "Servers",
        :type => :multiselect,
        :field => :servers,
        :mode => [:table, :show, :edit, :create],
        :checkbox_name => "server_group[server_ids][]",
        :items => servers(),
        :item_name_eval_fn => fn item -> Servers.server_name(item) end,
        :selected_item_ids => selected_servers(server_group_id)
      }
    ]
  end
end
