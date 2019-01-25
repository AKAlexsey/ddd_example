defmodule KalturaAdminWeb.SubnetControllerTest do
  use KalturaAdmin.ConnCase, async: false

  @create_attrs %{cidr: "#{Faker.Internet.ip_v4_address()}/30", name: "Old name"}
  @update_attrs %{cidr: "#{Faker.Internet.ip_v4_address()}/30", name: "New name"}
  @invalid_attrs %{cidr: nil, name: nil}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all subnetss", %{conn: conn} do
      conn = get(conn, subnet_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Subnetss"
    end
  end

  describe "new subnet" do
    test "renders form", %{conn: conn} do
      conn = get(conn, subnet_path(conn, :new))
      assert html_response(conn, 200) =~ "New Subnet"
    end
  end

  describe "create subnet" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, region} = Factory.insert(:region)
      create_attrs = Map.merge(@create_attrs, %{region_id: region.id})
      create_response = post(conn, subnet_path(conn, :create), subnet: create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == subnet_path(create_response, :show, id)

      show_response = get(conn, subnet_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Subnet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, subnet_path(conn, :create), subnet: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Subnet"
    end
  end

  describe "edit subnet" do
    setup [:create_subnet]

    test "renders form for editing chosen subnet", %{conn: conn, subnet: subnet} do
      conn = get(conn, subnet_path(conn, :edit, subnet))
      assert html_response(conn, 200) =~ "Edit Subnet"
    end
  end

  describe "update subnet" do
    setup [:create_subnet]

    test "redirects when data is valid", %{conn: conn, subnet: subnet} do
      update_response = put(conn, subnet_path(conn, :update, subnet), subnet: @update_attrs)
      assert redirected_to(update_response) == subnet_path(update_response, :show, subnet)

      show_response = get(conn, subnet_path(conn, :show, subnet))
      assert html_response(show_response, 200) =~ "New name"
    end

    test "renders errors when data is invalid", %{conn: conn, subnet: subnet} do
      conn = put(conn, subnet_path(conn, :update, subnet), subnet: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Subnet"
    end
  end

  describe "delete subnet" do
    setup [:create_subnet]

    test "deletes chosen subnet", %{conn: conn, subnet: subnet} do
      delete_response = delete(conn, subnet_path(conn, :delete, subnet))
      assert redirected_to(delete_response) == subnet_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, subnet_path(conn, :show, subnet))
      end)
    end
  end

  defp create_subnet(_) do
    {:ok, subnet} = Factory.insert(:subnet)
    {:ok, subnet: subnet}
  end
end
