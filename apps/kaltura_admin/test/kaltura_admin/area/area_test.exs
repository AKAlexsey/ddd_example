defmodule KalturaAdmin.AreaTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Area
  alias KalturaAdmin.Services.DomainModelCache
  import Mock

  describe "regions" do
    alias KalturaAdmin.Area.Region

    @valid_attrs %{
      description: "Old description",
      name: "Old name",
      status: :active
    }

    @update_attrs %{
      description: "New description",
      name: "New name",
      status: :inactive
    }

    @invalid_attrs %{description: nil, name: nil, status: nil}

    def region_fixture(attrs \\ %{}) do
      {:ok, region} = Factory.insert(:region, Enum.into(attrs, @valid_attrs))

      region
    end

    test "list_regions/0 returns all regions" do
      region = region_fixture()
      assert Enum.map(Area.list_regions(), & &1.id) == [region.id]
    end

    test "get_region!/1 returns the region with given id" do
      region = region_fixture()
      assert Area.get_region!(region.id).id == region.id
    end

    test "create_region/1 with valid data creates a region" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        assert {:ok, %Region{} = region} = Area.create_region(@valid_attrs)
        assert region.description == "Old description"
        assert region.name == "Old name"
        assert region.status == :active
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "create_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Area.create_region(@invalid_attrs)
    end

    test "update_region/2 with valid data updates the region" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        region = region_fixture()
        assert {:ok, %Region{} = region} = Area.update_region(region, @update_attrs)
        assert region.description == "New description"
        assert region.name == "New name"
        assert region.status == :inactive
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "update_region/2 with invalid data returns error changeset" do
      region = region_fixture()
      assert {:error, %Ecto.Changeset{}} = Area.update_region(region, @invalid_attrs)
      assert region.id == Area.get_region!(region.id).id
    end

    test "delete_region/1 deletes the region" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        region = region_fixture()
        assert {:ok, %Region{}} = Area.delete_region(region)
        assert_raise Ecto.NoResultsError, fn -> Area.get_region!(region.id) end
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "change_region/1 returns a region changeset" do
      region = region_fixture()
      assert %Ecto.Changeset{} = Area.change_region(region)
    end
  end

  describe "subnets" do
    alias KalturaAdmin.Area.Subnet

    @valid_attrs %{cidr: "123.123.123.123/30", name: "some name"}
    @update_attrs %{cidr: "123.123.123.124/30", name: "some updated name"}
    @invalid_attrs %{cidr: nil, name: nil}

    def subnet_fixture(attrs \\ %{}) do
      {:ok, subnet} = Factory.insert(:subnet, Enum.into(attrs, @valid_attrs))

      subnet
    end

    test "list_subnets/0 returns all subnets" do
      subnet = subnet_fixture()
      assert Area.list_subnets() == [subnet]
    end

    test "get_subnet!/1 returns the subnet with given id" do
      subnet = subnet_fixture()
      assert Area.get_subnet!(subnet.id) == subnet
    end

    test "create_subnet/1 with valid data creates a subnet" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        {:ok, region} = Factory.insert(:region)
        attrs = Map.put(@valid_attrs, :region_id, region.id)
        assert {:ok, %Subnet{} = subnet} = Area.create_subnet(attrs)
        assert subnet.cidr == "123.123.123.123/30"
        assert subnet.name == "some name"
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "create_subnet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Area.create_subnet(@invalid_attrs)
    end

    test "update_subnet/2 with valid data updates the subnet" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        subnet = subnet_fixture()
        assert {:ok, %Subnet{} = subnet} = Area.update_subnet(subnet, @update_attrs)
        assert subnet.cidr == "123.123.123.124/30"
        assert subnet.name == "some updated name"
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "update_subnet/2 with invalid data returns error changeset" do
      subnet = subnet_fixture()
      assert {:error, %Ecto.Changeset{}} = Area.update_subnet(subnet, @invalid_attrs)
      assert subnet == Area.get_subnet!(subnet.id)
    end

    test "delete_subnet/1 deletes the subnet" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        subnet = subnet_fixture()
        assert {:ok, %Subnet{}} = Area.delete_subnet(subnet)
        assert_raise Ecto.NoResultsError, fn -> Area.get_subnet!(subnet.id) end
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "change_subnet/1 returns a subnet changeset" do
      subnet = subnet_fixture()
      assert %Ecto.Changeset{} = Area.change_subnet(subnet)
    end
  end
end
