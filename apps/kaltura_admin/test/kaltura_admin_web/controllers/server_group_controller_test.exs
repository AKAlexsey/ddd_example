defmodule KalturaAdminWeb.ServerGroupControllerTest do
  use KalturaAdminWeb.ConnCase

  alias KalturaAdmin.Servers

  @create_attrs %{description: "some description", name: "some name", status: 42}
  @update_attrs %{description: "some updated description", name: "some updated name", status: 43}
  @invalid_attrs %{description: nil, name: nil, status: nil}

  def fixture(:server_group) do
    {:ok, server_group} = Servers.create_server_group(@create_attrs)
    server_group
  end

  describe "index" do
    test "lists all server_groups", %{conn: conn} do
      conn = get(conn, Routes.server_group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Server groups"
    end
  end

  describe "new server_group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.server_group_path(conn, :new))
      assert html_response(conn, 200) =~ "New Server group"
    end
  end

  describe "create server_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.server_group_path(conn, :create), server_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.server_group_path(conn, :show, id)

      conn = get(conn, Routes.server_group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Server group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.server_group_path(conn, :create), server_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Server group"
    end
  end

  describe "edit server_group" do
    setup [:create_server_group]

    test "renders form for editing chosen server_group", %{conn: conn, server_group: server_group} do
      conn = get(conn, Routes.server_group_path(conn, :edit, server_group))
      assert html_response(conn, 200) =~ "Edit Server group"
    end
  end

  describe "update server_group" do
    setup [:create_server_group]

    test "redirects when data is valid", %{conn: conn, server_group: server_group} do
      conn =
        put(
          conn,
          Routes.server_group_path(conn, :update, server_group),
          server_group: @update_attrs
        )

      assert redirected_to(conn) == Routes.server_group_path(conn, :show, server_group)

      conn = get(conn, Routes.server_group_path(conn, :show, server_group))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, server_group: server_group} do
      conn =
        put(
          conn,
          Routes.server_group_path(conn, :update, server_group),
          server_group: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Server group"
    end
  end

  describe "delete server_group" do
    setup [:create_server_group]

    test "deletes chosen server_group", %{conn: conn, server_group: server_group} do
      conn = delete(conn, Routes.server_group_path(conn, :delete, server_group))
      assert redirected_to(conn) == Routes.server_group_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.server_group_path(conn, :show, server_group))
      end)
    end
  end

  defp create_server_group(_) do
    server_group = fixture(:server_group)
    {:ok, server_group: server_group}
  end
end
