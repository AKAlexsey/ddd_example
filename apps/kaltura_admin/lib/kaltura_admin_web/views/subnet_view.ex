defmodule KalturaAdmin.SubnetView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Area

  def regions do
    Area.list_regions()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
