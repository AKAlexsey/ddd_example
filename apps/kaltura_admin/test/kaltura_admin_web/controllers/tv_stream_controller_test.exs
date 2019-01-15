defmodule KalturaAdminWeb.TvStreamControllerTest do
  use KalturaAdmin.ConnCase

  @create_attrs %{
    code_name: "OldName",
    description: Faker.Lorem.sentence(),
    dvr_enabled: false,
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word(),
    status: :active,
    stream_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"
  }
  @update_attrs %{
    code_name: "NewName",
    description: Faker.Lorem.sentence(),
    dvr_enabled: false,
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word(),
    status: :active,
    stream_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"
  }
  @invalid_attrs %{
    code_name: nil,
    description: nil,
    dvr_enabled: nil,
    epg_id: nil,
    name: nil,
    status: nil,
    stream_path: nil
  }

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all tv_streams", %{conn: conn} do
      conn = get(conn, tv_stream_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tv streams"
    end
  end

  describe "new tv_stream" do
    test "renders form", %{conn: conn} do
      conn = get(conn, tv_stream_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tv stream"
    end
  end

  describe "create tv_stream" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_response = post(conn, tv_stream_path(conn, :create), tv_stream: @create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == tv_stream_path(create_response, :show, id)

      show_response = get(conn, tv_stream_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Tv stream"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, tv_stream_path(conn, :create), tv_stream: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tv stream"
    end
  end

  describe "edit tv_stream" do
    setup [:create_tv_stream]

    test "renders form for editing chosen tv_stream", %{conn: conn, tv_stream: tv_stream} do
      conn = get(conn, tv_stream_path(conn, :edit, tv_stream))
      assert html_response(conn, 200) =~ "Edit Tv stream"
    end
  end

  describe "update tv_stream" do
    setup [:create_tv_stream]

    test "redirects when data is valid", %{conn: conn, tv_stream: tv_stream} do
      update_response =
        put(conn, tv_stream_path(conn, :update, tv_stream), tv_stream: @update_attrs)

      assert redirected_to(update_response) == tv_stream_path(update_response, :show, tv_stream)

      show_response = get(conn, tv_stream_path(conn, :show, tv_stream))
      assert html_response(show_response, 200) =~ "NewName"
    end

    test "renders errors when data is invalid", %{conn: conn, tv_stream: tv_stream} do
      conn = put(conn, tv_stream_path(conn, :update, tv_stream), tv_stream: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Tv stream"
    end
  end

  describe "delete tv_stream" do
    setup [:create_tv_stream]

    test "deletes chosen tv_stream", %{conn: conn, tv_stream: tv_stream} do
      delete_response = delete(conn, tv_stream_path(conn, :delete, tv_stream))
      assert redirected_to(delete_response) == tv_stream_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, tv_stream_path(conn, :show, tv_stream))
      end)
    end
  end

  defp create_tv_stream(_) do
    {:ok, tv_stream} = Factory.insert(:tv_stream)
    {:ok, tv_stream: tv_stream}
  end
end
