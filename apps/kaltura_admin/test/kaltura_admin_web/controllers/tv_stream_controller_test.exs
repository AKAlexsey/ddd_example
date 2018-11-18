defmodule KalturaAdminWeb.TvStreamControllerTest do
  use KalturaAdminWeb.ConnCase

  alias KalturaAdmin.Content

  @create_attrs %{
    code_name: "some code_name",
    description: "some description",
    dvr_enabled: true,
    epg_id: "some epg_id",
    name: "some name",
    status: 42,
    stream_path: "some stream_path"
  }
  @update_attrs %{
    code_name: "some updated code_name",
    description: "some updated description",
    dvr_enabled: false,
    epg_id: "some updated epg_id",
    name: "some updated name",
    status: 43,
    stream_path: "some updated stream_path"
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

  def fixture(:tv_stream) do
    {:ok, tv_stream} = Content.create_tv_stream(@create_attrs)
    tv_stream
  end

  describe "index" do
    test "lists all tv_streams", %{conn: conn} do
      conn = get(conn, Routes.tv_stream_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tv streams"
    end
  end

  describe "new tv_stream" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tv_stream_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tv stream"
    end
  end

  describe "create tv_stream" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tv_stream_path(conn, :create), tv_stream: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tv_stream_path(conn, :show, id)

      conn = get(conn, Routes.tv_stream_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tv stream"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tv_stream_path(conn, :create), tv_stream: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tv stream"
    end
  end

  describe "edit tv_stream" do
    setup [:create_tv_stream]

    test "renders form for editing chosen tv_stream", %{conn: conn, tv_stream: tv_stream} do
      conn = get(conn, Routes.tv_stream_path(conn, :edit, tv_stream))
      assert html_response(conn, 200) =~ "Edit Tv stream"
    end
  end

  describe "update tv_stream" do
    setup [:create_tv_stream]

    test "redirects when data is valid", %{conn: conn, tv_stream: tv_stream} do
      conn = put(conn, Routes.tv_stream_path(conn, :update, tv_stream), tv_stream: @update_attrs)
      assert redirected_to(conn) == Routes.tv_stream_path(conn, :show, tv_stream)

      conn = get(conn, Routes.tv_stream_path(conn, :show, tv_stream))
      assert html_response(conn, 200) =~ "some updated code_name"
    end

    test "renders errors when data is invalid", %{conn: conn, tv_stream: tv_stream} do
      conn = put(conn, Routes.tv_stream_path(conn, :update, tv_stream), tv_stream: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Tv stream"
    end
  end

  describe "delete tv_stream" do
    setup [:create_tv_stream]

    test "deletes chosen tv_stream", %{conn: conn, tv_stream: tv_stream} do
      conn = delete(conn, Routes.tv_stream_path(conn, :delete, tv_stream))
      assert redirected_to(conn) == Routes.tv_stream_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.tv_stream_path(conn, :show, tv_stream))
      end)
    end
  end

  defp create_tv_stream(_) do
    tv_stream = fixture(:tv_stream)
    {:ok, tv_stream: tv_stream}
  end
end
