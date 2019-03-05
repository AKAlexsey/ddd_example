defmodule KalturaAdmin.SubnetTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Area.Subnet

  describe "#changeset" do
    setup do
      {:ok, subnet} = Factory.insert(:subnet)

      {:ok, subnet: subnet}
    end

    test "Validate :cidr presence", %{subnet: subnet} do
      refute is_nil(subnet.cidr)
      changeset = Subnet.changeset(subnet, %{cidr: nil})

      assert %{valid?: false, errors: [cidr: _]} = changeset
    end

    test "Validate :region_id presence", %{subnet: subnet} do
      refute is_nil(subnet.region_id)
      changeset = Subnet.changeset(subnet, %{region_id: nil})

      assert %{valid?: false, errors: [region_id: _]} = changeset
    end

    test "Validate :name presence", %{subnet: subnet} do
      refute is_nil(subnet.name)
      changeset = Subnet.changeset(subnet, %{name: nil})

      assert %{valid?: false, errors: [name: _]} = changeset
    end

    test "Validate :cidr format", %{subnet: subnet} do
      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.i23/23"})
      assert %{valid?: false, errors: [cidr: _]} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123123/23"})
      assert %{valid?: false, errors: [cidr: _]} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123./23"})
      assert %{valid?: false, errors: [cidr: _]} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123/23"})
      assert %{valid?: false, errors: [cidr: _]} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.1123/23"})
      assert %{valid?: false, errors: [cidr: _]} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.256/23"})
      assert %{valid?: false} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.123/123"})
      assert %{valid?: false} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.123/"})
      assert %{valid?: false} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.123/33"})
      assert %{valid?: false} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.123/0"})
      assert %{valid?: true} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "183.134.153.134/32"})
      assert %{valid?: true} = changeset

      changeset = Subnet.changeset(subnet, %{cidr: "123.123.123.123/23"})
      assert %{valid?: true} = changeset
    end

    test "Validate :name is uniq", %{subnet: subnet} do
      {:ok, other_subnet} = Factory.insert(:subnet)

      refute subnet.name == other_subnet.name
      changeset = Subnet.changeset(subnet, %{name: other_subnet.name})
      assert {:error, %{valid?: false, errors: [name: _]}} = Repo.update(changeset)
    end
  end
end
