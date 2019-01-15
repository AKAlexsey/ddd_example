defmodule KalturaAdminWeb.ServerGroupControllerTest do
  use KalturaAdmin.ConnCase

  @create_attrs %{description: Faker.Lorem.sentence(), name: "Old name", status: :active}
  @update_attrs %{description: Faker.Lorem.sentence(), name: "New name", status: :active}
  @invalid_attrs %{description: nil, name: nil, status: nil}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all server_groups", %{conn: conn} do
      conn = get(conn, server_group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Server groups"
    end
  end

  describe "new server_group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, server_group_path(conn, :new))
      assert html_response(conn, 200) =~ "New Server group"
    end
  end

  describe "create server_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_response = post(conn, server_group_path(conn, :create), server_group: @create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == server_group_path(create_response, :show, id)

      show_response = get(conn, server_group_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Server group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, server_group_path(conn, :create), server_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Server group"
    end
  end

  describe "edit server_group" do
    setup [:create_server_group]

    test "renders form for editing chosen server_group", %{conn: conn, server_group: server_group} do
      conn = get(conn, server_group_path(conn, :edit, server_group))
      assert html_response(conn, 200) =~ "Edit Server group"
    end
  end

  describe "update server_group" do
    setup [:create_server_group]

    test "redirects when data is valid", %{conn: conn, server_group: server_group} do
      update_response =
        put(
          conn,
          server_group_path(conn, :update, server_group),
          server_group: @update_attrs
        )

      assert redirected_to(update_response) ==
               server_group_path(update_response, :show, server_group)

      show_response = get(conn, server_group_path(conn, :show, server_group))
      assert html_response(show_response, 200) =~ "New name"
    end

    test "renders errors when data is invalid", %{conn: conn, server_group: server_group} do
      conn =
        put(
          conn,
          server_group_path(conn, :update, server_group),
          server_group: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Server group"
    end
  end

  describe "delete server_group" do
    setup [:create_server_group]

    test "deletes chosen server_group", %{conn: conn, server_group: server_group} do
      delete_response = delete(conn, server_group_path(conn, :delete, server_group))
      assert redirected_to(delete_response) == server_group_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, server_group_path(conn, :show, server_group))
      end)
    end
  end

  defp create_server_group(_) do
    {:ok, server_group} = Factory.insert(:server_group)
    {:ok, server_group: server_group}
  end
end
