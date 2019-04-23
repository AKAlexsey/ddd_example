defmodule CtiKaltura.ServerControllerTest do
  use CtiKaltura.ConnCase

  @create_attrs %{
    domain_name: "some-domain.name",
    healthcheck_enabled: true,
    healthcheck_path: "/some-healthcheck-path",
    ip: Faker.Internet.ip_v4_address(),
    manage_ip: Faker.Internet.ip_v4_address(),
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
    ip: Faker.Internet.ip_v4_address(),
    manage_ip: Faker.Internet.ip_v4_address(),
    manage_port: 43,
    port: 443,
    status: "ACTIVE",
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

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all servers", %{conn: conn} do
      conn = get(conn, server_path(conn, :index))
      assert html_response(conn, 200) =~ "Servers"
    end
  end

  describe "new server" do
    test "renders form", %{conn: conn} do
      conn = get(conn, server_path(conn, :new))
      assert html_response(conn, 200) =~ "New Server"
    end
  end

  describe "create server" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_response = post(conn, server_path(conn, :create), server: @create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == server_path(create_response, :show, id)

      show_response = get(conn, server_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Server"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, server_path(conn, :create), server: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Server"
    end
  end

  describe "edit server" do
    setup [:create_server]

    test "renders form for editing chosen server", %{conn: conn, server: server} do
      conn = get(conn, server_path(conn, :edit, server))
      assert html_response(conn, 200) =~ "Edit Server"
    end
  end

  describe "update server" do
    setup [:create_server]

    test "redirects when data is valid", %{conn: conn, server: server} do
      update_response = put(conn, server_path(conn, :update, server), server: @update_attrs)
      assert redirected_to(update_response) == server_path(update_response, :show, server)

      show_response = get(conn, server_path(conn, :show, server))
      assert html_response(show_response, 200) =~ "some-updated-domain.name"
    end

    test "renders errors when data is invalid", %{conn: conn, server: server} do
      conn = put(conn, server_path(conn, :update, server), server: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Server"
    end
  end

  describe "delete server" do
    setup [:create_server]

    test "deletes chosen server", %{conn: conn, server: server} do
      delete_response = delete(conn, server_path(conn, :delete, server))
      assert redirected_to(delete_response) == server_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, server_path(conn, :show, server))
      end)
    end
  end

  defp create_server(_) do
    {:ok, server} = Factory.insert_and_notify(:server)
    {:ok, server: server}
  end
end
