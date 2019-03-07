defmodule KalturaAdmin.SubnetView do
  use KalturaAdminWeb, :view

  alias KalturaAdmin.Area

  def regions do
    Area.list_regions()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  def region_name_by_id(region_id) do
    regions()
    |> Enum.filter(fn {_, id} -> id == region_id end)
    |> Enum.at(0)
    |> Tuple.to_list()
    |> Enum.at(0)
  end

  def region_name_by_id(regions_as_tuple_list, region_id) do
    regions_as_tuple_list
    |> Enum.filter(fn {_, id} -> id == region_id end)
    |> Enum.at(0)
    |> Tuple.to_list()
    |> Enum.at(0)
  end
end
