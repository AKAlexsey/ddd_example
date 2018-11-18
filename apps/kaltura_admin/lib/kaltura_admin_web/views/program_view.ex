defmodule KalturaAdmin.ProgramView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Content

  def tv_streams do
    Content.list_tv_streams()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
