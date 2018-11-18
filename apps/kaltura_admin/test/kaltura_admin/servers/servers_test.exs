defmodule KalturaAdmin.ServersTest do
  use KalturaAdmin.DataCase

  alias KalturaAdmin.Servers

  describe "servers" do
    alias KalturaAdmin.Servers.Server

    @valid_attrs %{
      domain_name: "some domain_name",
      healthcheck_enabled: true,
      healthcheck_path: "some healthcheck_path",
      ip: "some ip",
      manage_ip: "some manage_ip",
      manage_port: 42,
      port: 42,
      prefix: "some prefix",
      status: 42,
      type: 42,
      weight: 42
    }
    @update_attrs %{
      domain_name: "some updated domain_name",
      healthcheck_enabled: false,
      healthcheck_path: "some updated healthcheck_path",
      ip: "some updated ip",
      manage_ip: "some updated manage_ip",
      manage_port: 43,
      port: 43,
      prefix: "some updated prefix",
      status: 43,
      type: 43,
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
      {:ok, server} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Servers.create_server()

      server
    end

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Servers.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Servers.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      assert {:ok, %Server{} = server} = Servers.create_server(@valid_attrs)
      assert server.domain_name == "some domain_name"
      assert server.healthcheck_enabled == true
      assert server.healthcheck_path == "some healthcheck_path"
      assert server.ip == "some ip"
      assert server.manage_ip == "some manage_ip"
      assert server.manage_port == 42
      assert server.port == 42
      assert server.prefix == "some prefix"
      assert server.status == 42
      assert server.type == 42
      assert server.weight == 42
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()
      assert {:ok, %Server{} = server} = Servers.update_server(server, @update_attrs)
      assert server.domain_name == "some updated domain_name"
      assert server.healthcheck_enabled == false
      assert server.healthcheck_path == "some updated healthcheck_path"
      assert server.ip == "some updated ip"
      assert server.manage_ip == "some updated manage_ip"
      assert server.manage_port == 43
      assert server.port == 43
      assert server.prefix == "some updated prefix"
      assert server.status == 43
      assert server.type == 43
      assert server.weight == 43
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Servers.update_server(server, @invalid_attrs)
      assert server == Servers.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Servers.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Servers.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Servers.change_server(server)
    end
  end

  describe "server_groups" do
    alias KalturaAdmin.Servers.ServerGroup

    @valid_attrs %{description: "some description", name: "some name", status: 42}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      status: 43
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
      assert Servers.list_server_groups() == [server_group]
    end

    test "get_server_group!/1 returns the server_group with given id" do
      server_group = server_group_fixture()
      assert Servers.get_server_group!(server_group.id) == server_group
    end

    test "create_server_group/1 with valid data creates a server_group" do
      assert {:ok, %ServerGroup{} = server_group} = Servers.create_server_group(@valid_attrs)
      assert server_group.description == "some description"
      assert server_group.name == "some name"
      assert server_group.status == 42
    end

    test "create_server_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server_group(@invalid_attrs)
    end

    test "update_server_group/2 with valid data updates the server_group" do
      server_group = server_group_fixture()

      assert {:ok, %ServerGroup{} = server_group} =
               Servers.update_server_group(server_group, @update_attrs)

      assert server_group.description == "some updated description"
      assert server_group.name == "some updated name"
      assert server_group.status == 43
    end

    test "update_server_group/2 with invalid data returns error changeset" do
      server_group = server_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Servers.update_server_group(server_group, @invalid_attrs)

      assert server_group == Servers.get_server_group!(server_group.id)
    end

    test "delete_server_group/1 deletes the server_group" do
      server_group = server_group_fixture()
      assert {:ok, %ServerGroup{}} = Servers.delete_server_group(server_group)
      assert_raise Ecto.NoResultsError, fn -> Servers.get_server_group!(server_group.id) end
    end

    test "change_server_group/1 returns a server_group changeset" do
      server_group = server_group_fixture()
      assert %Ecto.Changeset{} = Servers.change_server_group(server_group)
    end
  end
end
