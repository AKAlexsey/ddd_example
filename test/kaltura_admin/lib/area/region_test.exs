defmodule CtiKaltura.RegionTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Area.Region

  describe "#changeset" do
    setup do
      {:ok, region} = Factory.insert(:region)

      {:ok, region: region}
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

    test "Validate :name is uniq", %{region: region} do
      {:ok, other_server_group} = Factory.insert(:region)

      refute region.name == other_server_group.name
      changeset = Region.changeset(region, %{name: other_server_group.name})
      assert {:error, %{valid?: false, errors: [name: _]}} = Repo.update(changeset)
    end
  end
end
