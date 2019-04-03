defmodule CtiKaltura.RegionTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Area
  alias CtiKaltura.Area.Region

  describe "#changeset" do
    setup do
      {:ok, %{:id => server_group_id}} = Factory.insert(:server_group)
      {:ok, region} = Factory.insert(:region, %{:server_group_ids => [server_group_id]})
      Factory.insert(:subnet, %{:region_id => region.id})

      {:ok, region: region, region_id: region.id}
    end

    test "Validate :name presence", %{region: region} do
      refute is_nil(region.name)
      changeset = Region.changeset(region, %{name: nil})

      assert %{valid?: false, errors: [name: _]} = changeset
    end

    test "Validate :status presence", %{region: region} do
      refute is_nil(region.status)
      changeset = Region.changeset(region, %{status: nil})

      assert %{valid?: false, errors: [status: _]} = changeset
    end

    test "Validate :name is unique", %{region: region} do
      {:ok, other_server_group} = Factory.insert(:region)

      refute region.name == other_server_group.name
      changeset = Region.changeset(region, %{name: other_server_group.name})
      assert {:error, %{valid?: false, errors: [name: _]}} = Repo.update(changeset)
    end

    test "Delete region", %{region_id: region_id} do
      region = Repo.get(Region, region_id)
      assert region != nil
      Area.delete_region(region)
      assert Repo.get(Region, region_id) == nil
    end
  end
end
