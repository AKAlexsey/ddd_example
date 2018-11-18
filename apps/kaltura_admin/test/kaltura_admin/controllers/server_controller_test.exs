defmodule KalturaAdmin.ServerControllerTest do
  use KalturaAdmin.ConnCase

  alias KalturaAdmin.Servers

  @create_attrs %{
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

  def fixture(:server) do
    {:ok, server} = Servers.create_server(@create_attrs)
    server
  end

  describe "index" do
    test "lists all servers", %{conn: conn} do
      conn = get(conn, Routes.server_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Servers"
    end
  end

  describe "new server" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.server_path(conn, :new))
      assert html_response(conn, 200) =~ "New Server"
    end
  end

  describe "create server" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.server_path(conn, :create), server: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.server_path(conn, :show, id)

      conn = get(conn, Routes.server_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Server"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.server_path(conn, :create), server: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Server"
    end
  end

  describe "edit server" do
    setup [:create_server]

    test "renders form for editing chosen server", %{conn: conn, server: server} do
      conn = get(conn, Routes.server_path(conn, :edit, server))
      assert html_response(conn, 200) =~ "Edit Server"
    end
  end

  describe "update server" do
    setup [:create_server]

    test "redirects when data is valid", %{conn: conn, server: server} do
      conn = put(conn, Routes.server_path(conn, :update, server), server: @update_attrs)
      assert redirected_to(conn) == Routes.server_path(conn, :show, server)

      conn = get(conn, Routes.server_path(conn, :show, server))
      assert html_response(conn, 200) =~ "some updated domain_name"
    end

    test "renders errors when data is invalid", %{conn: conn, server: server} do
      conn = put(conn, Routes.server_path(conn, :update, server), server: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Server"
    end
  end

  describe "delete server" do
    setup [:create_server]

    test "deletes chosen server", %{conn: conn, server: server} do
      conn = delete(conn, Routes.server_path(conn, :delete, server))
      assert redirected_to(conn) == Routes.server_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.server_path(conn, :show, server))
      end)
    end
  end

  defp create_server(_) do
    server = fixture(:server)
    {:ok, server: server}
  end
end
