defmodule CtiKaltura.ProgramView do
  use CtiKalturaWeb, :view

  alias CtiKaltura.Content
  alias CtiKaltura.Servers
  alias CtiKaltura.Util

  def linear_channels do
    Content.list_linear_channels()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def as_html_period(item) do
    "<span class=\"date\">#{Util.date_to_string(item.start_datetime)}</span> [ #{
      Util.time_to_string(item.start_datetime)
    } - #{Util.time_to_string(item.end_datetime)} ]"
  end

  def linear_channel_name(%{linear_channel: linear_channel}) when not is_nil(linear_channel) do
    linear_channel.name
  end

  def linear_channel_name(_), do: ""

  def dvr_servers do
    Servers.list_dvr_servers()
    |> Enum.map(fn item -> {Servers.server_name(item), item.id} end)
  end

  def recording_programs do
    Content.list_programs()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def program_records(program_id) do
    Content.list_program_records(program_id)
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
        :header => "Period",
        :type => :string,
        :mode => [:table, :show],
        :eval_html_fn => fn ob -> as_html_period(ob) end
      },
      %{
        :header => "Period start",
        :type => :datetime,
        :field => :start_datetime,
        :mode => [:edit, :create]
      },
      %{
        :header => "Period end",
        :type => :datetime,
        :field => :end_datetime,
        :mode => [:edit, :create]
      },
      %{
        :header => "EPG ID",
        :type => :string,
        :field => :epg_id,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "TV channel",
        :type => :select_entity,
        :field => :linear_channel_id,
        :mode => [:table, :show, :edit, :create],
        :items => linear_channels()
      }
    ]
  end

  def program_record_meta do
    [
      %{
        :header => "Protocol",
        :type => :select,
        :field => :protocol,
        :mode => [:table, :show, :edit, :create],
        :items => stream_protocols()
      },
      %{
        :header => "Encryption",
        :type => :select,
        :field => :encryption,
        :mode => [:table, :show, :edit, :create],
        :items => encryptions()
      },
      %{
        :header => "Status",
        :type => :select,
        :field => :status,
        :mode => [:table, :show, :edit, :create],
        :items => recording_statuses()
      },
      %{
        :header => "Path",
        :type => :string,
        :field => :path,
        :mode => [:table, :show, :edit, :create]
      },
      %{
        :header => "DVR server",
        :type => :select_entity,
        :field => :server_id,
        :mode => [:table, :show, :edit, :create],
        :items => dvr_servers()
      },
      %{
        :header => "Hidden program_id",
        :type => :hidden,
        :field => :program_id,
        :mode => [:create]
      }
    ]
  end
end
