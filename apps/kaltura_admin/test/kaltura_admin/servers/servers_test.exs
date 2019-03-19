defmodule KalturaAdmin.ServersTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Servers
  import Mock
  alias KalturaAdmin.Services.DomainModelCache

  describe "servers" do
    alias KalturaAdmin.Servers.Server

    @valid_attrs %{
      domain_name: "some-domain.name",
      healthcheck_enabled: true,
      healthcheck_path: "/some-healthcheck-path",
      ip: "123.123.123.123",
      manage_ip: "123.123.123.123",
      manage_port: 42,
      port: 80,
      prefix: "some-prefix",
      status: "ACTIVE",
      type: "EDGE",
      weight: 42
    }
    @update_attrs %{
      domain_name: "some-updated-domain.name",
      healthcheck_enabled: false,
      healthcheck_path: "/some-updated-healthcheck-path",
      ip: "124.124.124.124",
      manage_ip: "124.124.124.124",
      manage_port: 43,
      port: 443,
      prefix: "some-updated-prefix",
      status: "INACTIVE",
      type: "EDGE",
      weight: 43
    }
    @invalid_attrs %{
      domain_name: nil,
      healthcheck_enabled: nil,
      healthcheck_path: nil,
      ip: nil,
      manage_ip: nil,
      manage_port: nil,
      port: nil,
      prefix: nil,
      status: nil,
      type: nil,
      weight: nil
    }

    def server_fixture(attrs \\ %{}) do
      {:ok, server} = Factory.insert(:server, Enum.into(attrs, @valid_attrs))

      server
    end

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Enum.map(Servers.list_servers(), & &1.id) == [server.id]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Servers.get_server!(server.id).id == server.id
    end

    test "create_server/1 with valid data creates a server" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        assert {:ok, %Server{} = server} = Servers.create_server(@valid_attrs)
        assert server.domain_name == "some-domain.name"
        assert server.healthcheck_enabled == true
        assert server.healthcheck_path == "/some-healthcheck-path"
        assert server.ip == "123.123.123.123"
        assert server.manage_ip == "123.123.123.123"
        assert server.manage_port == 42
        assert server.port == 80
        assert server.prefix == "some-prefix"
        assert server.status == "ACTIVE"
        assert server.type == "EDGE"
        assert server.weight == 42
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        server = server_fixture()
        assert {:ok, %Server{} = server} = Servers.update_server(server, @update_attrs)
        assert server.domain_name == "some-updated-domain.name"
        assert server.healthcheck_enabled == false
        assert server.healthcheck_path == "/some-updated-healthcheck-path"
        assert server.ip == "124.124.124.124"
        assert server.manage_ip == "124.124.124.124"
        assert server.manage_port == 43
        assert server.port == 443
        assert server.prefix == "some-updated-prefix"
        assert server.status == "INACTIVE"
        assert server.type == "EDGE"
        assert server.weight == 43
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Servers.update_server(server, @invalid_attrs)
      assert server.id == Servers.get_server!(server.id).id
    end

    test "delete_server/1 deletes the server" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        server = server_fixture()
        assert {:ok, %Server{}} = Servers.delete_server(server)
        assert_raise Ecto.NoResultsError, fn -> Servers.get_server!(server.id) end
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Servers.change_server(server)
    end
  end

  describe "server_groups" do
    alias KalturaAdmin.Servers.ServerGroup

    @valid_attrs %{description: "some description", name: "some name", status: "ACTIVE"}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      status: "INACTIVE"
    }
    @invalid_attrs %{description: nil, name: nil, status: nil}

    def server_group_fixture(attrs \\ %{}) do
      {:ok, server_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Servers.create_server_group()

      server_group
    end

    test "list_server_groups/0 returns all server_groups" do
      server_group = server_group_fixture()
      assert Enum.map(Servers.list_server_groups(), & &1.id) == [server_group.id]
    end

    test "get_server_group!/1 returns the server_group with given id" do
      server_group = server_group_fixture()
      assert Servers.get_server_group!(server_group.id).id == server_group.id
    end

    test "create_server_group/1 with valid data creates a server_group" do
      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        assert {:ok, %ServerGroup{} = server_group} = Servers.create_server_group(@valid_attrs)
        assert server_group.description == "some description"
        assert server_group.name == "some name"
        assert server_group.status == "ACTIVE"
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "create_server_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server_group(@invalid_attrs)
    end

    test "update_server_group/2 with valid data updates the server_group" do
      server_group = server_group_fixture()

      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        assert {:ok, %ServerGroup{} = server_group} =
                 Servers.update_server_group(server_group, @update_attrs)

        assert server_group.description == "some updated description"
        assert server_group.name == "some updated name"
        assert server_group.status == "INACTIVE"
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "update_server_group/2 with invalid data returns error changeset" do
      server_group = server_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Servers.update_server_group(server_group, @invalid_attrs)

      assert server_group.id == Servers.get_server_group!(server_group.id).id
    end

    test "delete_server_group/1 deletes the server_group" do
      server_group = server_group_fixture()

      with_mock DomainModelCache, get_all_records: fn -> :ok end do
        assert {:ok, %ServerGroup{}} = Servers.delete_server_group(server_group)
        assert_raise Ecto.NoResultsError, fn -> Servers.get_server_group!(server_group.id) end
        assert_called(DomainModelCache.get_all_records())
      end
    end

    test "change_server_group/1 returns a server_group changeset" do
      server_group = server_group_fixture()
      assert %Ecto.Changeset{} = Servers.change_server_group(server_group)
    end
  end
end
