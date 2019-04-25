defmodule CtiKaltura.RegionTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Area
  alias CtiKaltura.Area.{Region, Subnet}

  describe "#changeset" do
    setup do
      {:ok, %{:id => server_group_id}} = Factory.insert(:server_group)
      {:ok, region} = Factory.insert(:region, %{:server_group_ids => [server_group_id]})
      {:ok, subnet} = Factory.insert(:subnet, %{:region_id => region.id})

      {:ok, region: region, region_id: region.id, subnet_id: subnet.id}
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

    test "Delete region fails if there is associated Subnets", %{region_id: region_id} do
      region = Repo.get(Region, region_id)
      assert region != nil
      assert {:error, %{errors: errors}} = Area.delete_region(region)
      assert [subnets: _] = errors
    end

    test "Delete region if it does not have Subnets", %{
      region_id: region_id,
      subnet_id: subnet_id
    } do
      Area.delete_subnet(Repo.get(Subnet, subnet_id))
      region = Repo.get(Region, region_id)
      assert region != nil
      assert {:ok, _} = Area.delete_region(region)

      assert Repo.get(Region, region_id) == nil
    end
  end
end
