defmodule CtiKaltura.ServerView do
  use CtiKalturaWeb, :view
  alias CtiKaltura.Servers

  def server_groups do
    Servers.list_server_groups()
    |> Enum.map(fn %{name: name, id: id} -> {name, id} end)
  end

  def selected_server_groups(nil), do: []

  def selected_server_groups(server_id) do
    Servers.server_groups_ids_for_server(server_id)
  end

  def meta(server \\ nil) do
    server_id =
      if server == nil do
        nil
      else
        server.id
      end

    [
      %{
        :header => "Server name",
        :type => :string,
        :mode => [:table],
        :eval_fn => fn ob -> "#{ob.domain_name} [#{ob.type}]" end
      },
      %{
        :header => "Domain name",
        :type => :string,
        :field => :domain_name,
        :mode => [:show, :edit, :create]
      },
      %{
        :header => "Status",
        :type => :status,
        :field => :status,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Type",
        :type => :select,
        :field => :type,
        :mode => [:show, :edit, :create],
        :items => server_types()
      },
      %{:header => "IP", :type => :string, :field => :ip, :mode => [:table, :edit, :create]},
      %{:header => "Port", :type => :string, :field => :port, :mode => [:edit, :create]},
      %{
        :header => "Manage IP",
        :type => :string,
        :field => :manage_ip,
        :mode => [:edit, :create]
      },
      %{
        :header => "Manage port",
        :type => :string,
        :field => :manage_port,
        :mode => [:edit, :create]
      },
      %{
        :header => "Address",
        :type => :string,
        :mode => [:show],
        :eval_fn => fn ob -> "#{ob.ip}:#{ob.port}" end
      },
      %{
        :header => "Managed address",
        :type => :string,
        :mode => [:show],
        :eval_fn => fn ob -> "#{ob.manage_ip}:#{ob.manage_port}" end
      },
      %{
        :header => "Prefix",
        :type => :string,
        :field => :prefix,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Weight",
        :type => :string,
        :field => :weight,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Healthcheck",
        :type => :boolean,
        :field => :healthcheck_enabled,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Healthcheck path",
        :type => :string,
        :field => :healthcheck_path,
        :mode => [:show, :edit, :create]
      },
      %{
        :header => "Server groups",
        :type => :multiselect,
        :field => :server_groups,
        :mode => [:table, :show, :edit, :create],
        :checkbox_name => "server[server_group_ids][]",
        :items => server_groups(),
        :item_name_eval_fn => fn item -> item.name end,
        :selected_item_ids => selected_server_groups(server_id)
      }
    ]
  end
end
