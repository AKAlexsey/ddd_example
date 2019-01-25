defmodule KalturaAdmin.ProgramRecordView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Content
  alias KalturaAdmin.Servers

  def dvr_servers do
    # TODO request only DVR servers
    Servers.list_servers()
    |> Enum.map(fn %{id: id, domain_name: name} -> {name, id} end)
  end

  def recording_programs do
    Content.list_programs()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
