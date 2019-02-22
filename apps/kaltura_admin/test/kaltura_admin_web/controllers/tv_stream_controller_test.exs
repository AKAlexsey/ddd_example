defmodule KalturaAdminWeb.TvStreamControllerTest do
  use KalturaAdmin.ConnCase, async: false

  alias KalturaAdmin.Repo
  alias KalturaAdmin.Content.TvStream

  @create_attrs %{
    encryption: "some encryption",
    protocol: "some protocol",
    status: "some status",
    stream_path: "some stream_path"
  }
  # @update_attrs %{encryption: "some updated encryption", protocol: "some updated protocol", status: "some updated status", stream_path: "some updated stream_path"}
  @invalid_attrs %{encryption: nil, protocol: nil, status: nil, stream_path: nil}

  def fixture(:tv_stream) do
    {:ok, tv_stream} = Factory.insert(@create_attrs)
    tv_stream
  end

  setup tags do
    {:ok, user} = Factory.insert(:admin)
    {:ok, linear_channel} = Factory.insert(:linear_channel)

    {:ok, conn: authorize(tags[:conn], user), linear_channel: linear_channel}
  end

  describe "create tv_stream" do
    test "redirects to show when data is valid", %{conn: conn, linear_channel: linear_channel} do
      before_tv_stream_count = Repo.aggregate(TvStream, :count, :id)

      conn =
        post(
          conn,
          tv_stream_path(conn, :create),
          tv_stream: Map.put(@create_attrs, :linear_channel_id, linear_channel.id)
        )

      assert redirected_to(conn) == linear_channel_path(conn, :edit, linear_channel)

      assert before_tv_stream_count + 1 == Repo.aggregate(TvStream, :count, :id)
    end

    test "renders errors when data is invalid", %{conn: conn, linear_channel: linear_channel} do
      before_tv_stream_count = Repo.aggregate(TvStream, :count, :id)

      conn =
        post(
          conn,
          tv_stream_path(conn, :create),
          tv_stream: Map.put(@invalid_attrs, :linear_channel_id, linear_channel.id)
        )

      assert redirected_to(conn) == linear_channel_path(conn, :edit, linear_channel)
      assert before_tv_stream_count == Repo.aggregate(TvStream, :count, :id)
    end
  end

  # TODO Возможно в будущем сделаем редактирование
  #  describe "edit tv_stream" do
  #    setup [:create_tv_stream]
  #
  #    test "renders form for editing chosen tv_stream", %{conn: conn, tv_stream: tv_stream} do
  #      conn = get(conn, tv_stream_path(conn, :edit, tv_stream))
  #      assert html_response(conn, 200) =~ "Edit Tv stream"
  #    end
  #  end
  #
  #  describe "update tv_stream" do
  #    setup [:create_tv_stream]
  #
  #    test "redirects when data is valid", %{conn: conn, tv_stream: tv_stream} do
  #      conn = put(conn, tv_stream_path(conn, :update, tv_stream), tv_stream: @update_attrs)
  #      assert redirected_to(conn) == tv_stream_path(conn, :show, tv_stream)
  #
  #      conn = get(conn, tv_stream_path(conn, :show, tv_stream))
  #      assert html_response(conn, 200) =~ "some updated encryption"
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn, tv_stream: tv_stream} do
  #      conn = put(conn, tv_stream_path(conn, :update, tv_stream), tv_stream: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "Edit Tv stream"
  #    end
  #  end

  describe "delete tv_stream" do
    setup [:create_tv_stream]

    test "deletes chosen tv_stream", %{
      conn: conn,
      tv_stream: tv_stream,
      linear_channel: linear_channel
    } do
      conn = delete(conn, tv_stream_path(conn, :delete, tv_stream))
      assert redirected_to(conn) == linear_channel_path(conn, :edit, linear_channel)
      assert 0 == Repo.aggregate(TvStream, :count, :id)
    end
  end

  defp create_tv_stream(_) do
    {:ok, linear_channel} = Factory.insert(:linear_channel)
    {:ok, tv_stream} = Factory.insert(:tv_stream, %{linear_channel_id: linear_channel.id})
    {:ok, tv_stream: tv_stream, linear_channel: linear_channel}
  end
end
