defmodule KalturaAdminWeb.RegionControllerTest do
  use KalturaAdmin.ConnCase

  @create_attrs %{description: Faker.Lorem.sentence(), name: "Old name", status: :active}
  @update_attrs %{description: Faker.Lorem.sentence(), name: "New name", status: :inactive}
  @invalid_attrs %{description: nil, name: nil, status: nil}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all regions", %{conn: conn} do
      conn = get(conn, region_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Regions"
    end
  end

  describe "new region" do
    test "renders form", %{conn: conn} do
      conn = get(conn, region_path(conn, :new))
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "create region" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_response = post(conn, region_path(conn, :create), region: @create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == region_path(create_response, :show, id)

      show_response = get(conn, region_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Region"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, region_path(conn, :create), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Region"
    end
  end

  describe "edit region" do
    setup [:create_region]

    test "renders form for editing chosen region", %{conn: conn, region: region} do
      conn = get(conn, region_path(conn, :edit, region))
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "update region" do
    setup [:create_region]

    test "redirects when data is valid", %{conn: conn, region: region} do
      update_reponse = put(conn, region_path(conn, :update, region), region: @update_attrs)
      assert redirected_to(update_reponse) == region_path(update_reponse, :show, region)

      show_response = get(conn, region_path(conn, :show, region))
      assert html_response(show_response, 200) =~ "New name"
    end

    test "renders errors when data is invalid", %{conn: conn, region: region} do
      conn = put(conn, region_path(conn, :update, region), region: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Region"
    end
  end

  describe "delete region" do
    setup [:create_region]

    test "deletes chosen region", %{conn: conn, region: region} do
      delete_response = delete(conn, region_path(conn, :delete, region))
      assert redirected_to(delete_response) == region_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, region_path(conn, :show, region))
      end)
    end
  end

  defp create_region(_) do
    {:ok, region} = Factory.insert(:region)
    {:ok, region: region}
  end
end
