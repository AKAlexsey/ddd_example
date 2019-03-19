defmodule KalturaAdmin.LinearChannelView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Content.TvStream
  alias KalturaAdmin.{Repo, Servers}

  import Ecto.Query

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

  def tv_streams(linear_channel_id) do
    Repo.all(from(stream in TvStream, where: stream.linear_channel_id == ^linear_channel_id))
  end

  def meta do
    [
      %{
        :header => "Name",
        :type => :string,
        :field => :name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Code name",
        :type => :string,
        :field => :code_name,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Description",
        :type => :textarea,
        :field => :description,
        :mode => [:show, :edit, :create]
      },
      %{
        :header => "Epg ID",
        :type => :string,
        :field => :epg_id,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Recording",
        :type => :boolean,
        :field => :dvr_enabled,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Recording server group",
        :type => :select_entity,
        :field => :server_group_id,
        :mode => [:table, :show, :edit, :create],
        :items => server_groups()
      }
    ]
  end

  def tv_stream_meta do
    [
      %{
        :header => "Stream path",
        :type => :string,
        :field => :stream_path,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Status",
        :type => :select,
        :field => :status,
        :items => recording_statuses(),
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Protocol",
        :type => :select,
        :field => :protocol,
        :items => stream_protocols(),
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Encryption",
        :type => :select,
        :field => :encryption,
        :items => encryptions(),
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "Hidden linear_channel_id",
        :type => :hidden,
        :field => :linear_channel_id,
        :mode => [:create]
      }
    ]
  end
end
