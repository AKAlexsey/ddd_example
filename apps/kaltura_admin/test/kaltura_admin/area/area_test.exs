defmodule KalturaAdmin.AreaTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Area

  describe "regions" do
    alias KalturaAdmin.Area.Region

    @valid_attrs %{description: "some description", name: "some name", status: 42}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      status: 43
    }
    @invalid_attrs %{description: nil, name: nil, status: nil}

    def region_fixture(attrs \\ %{}) do
      {:ok, region} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Area.create_region()

      region
    end

    test "list_regions/0 returns all regions" do
      region = region_fixture()
      assert Area.list_regions() == [region]
    end

    test "get_region!/1 returns the region with given id" do
      region = region_fixture()
      assert Area.get_region!(region.id) == region
    end

    test "create_region/1 with valid data creates a region" do
      assert {:ok, %Region{} = region} = Area.create_region(@valid_attrs)
      assert region.description == "some description"
      assert region.name == "some name"
      assert region.status == 42
    end

    test "create_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Area.create_region(@invalid_attrs)
    end

    test "update_region/2 with valid data updates the region" do
      region = region_fixture()
      assert {:ok, %Region{} = region} = Area.update_region(region, @update_attrs)
      assert region.description == "some updated description"
      assert region.name == "some updated name"
      assert region.status == 43
    end

    test "update_region/2 with invalid data returns error changeset" do
      region = region_fixture()
      assert {:error, %Ecto.Changeset{}} = Area.update_region(region, @invalid_attrs)
      assert region == Area.get_region!(region.id)
    end

    test "delete_region/1 deletes the region" do
      region = region_fixture()
      assert {:ok, %Region{}} = Area.delete_region(region)
      assert_raise Ecto.NoResultsError, fn -> Area.get_region!(region.id) end
    end

    test "change_region/1 returns a region changeset" do
      region = region_fixture()
      assert %Ecto.Changeset{} = Area.change_region(region)
    end
  end

  describe "subnetss" do
    alias KalturaAdmin.Area.Subnet

    @valid_attrs %{cidr: "some cidr", name: "some name"}
    @update_attrs %{cidr: "some updated cidr", name: "some updated name"}
    @invalid_attrs %{cidr: nil, name: nil}

    def subnet_fixture(attrs \\ %{}) do
      {:ok, subnet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Area.create_subnet()

      subnet
    end

    test "list_subnetss/0 returns all subnetss" do
      subnet = subnet_fixture()
      assert Area.list_subnetss() == [subnet]
    end

    test "get_subnet!/1 returns the subnet with given id" do
      subnet = subnet_fixture()
      assert Area.get_subnet!(subnet.id) == subnet
    end

    test "create_subnet/1 with valid data creates a subnet" do
      assert {:ok, %Subnet{} = subnet} = Area.create_subnet(@valid_attrs)
      assert subnet.cidr == "some cidr"
      assert subnet.name == "some name"
    end

    test "create_subnet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Area.create_subnet(@invalid_attrs)
    end

    test "update_subnet/2 with valid data updates the subnet" do
      subnet = subnet_fixture()
      assert {:ok, %Subnet{} = subnet} = Area.update_subnet(subnet, @update_attrs)
      assert subnet.cidr == "some updated cidr"
      assert subnet.name == "some updated name"
    end

    test "update_subnet/2 with invalid data returns error changeset" do
      subnet = subnet_fixture()
      assert {:error, %Ecto.Changeset{}} = Area.update_subnet(subnet, @invalid_attrs)
      assert subnet == Area.get_subnet!(subnet.id)
    end

    test "delete_subnet/1 deletes the subnet" do
      subnet = subnet_fixture()
      assert {:ok, %Subnet{}} = Area.delete_subnet(subnet)
      assert_raise Ecto.NoResultsError, fn -> Area.get_subnet!(subnet.id) end
    end

    test "change_subnet/1 returns a subnet changeset" do
      subnet = subnet_fixture()
      assert %Ecto.Changeset{} = Area.change_subnet(subnet)
    end
  end
end
