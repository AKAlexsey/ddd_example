defmodule CtiKalturaWeb.LinearChannelControllerTest do
  use CtiKaltura.ConnCase

  @create_attrs %{
    code_name: "OldName",
    description: Faker.Lorem.sentence(),
    dvr_enabled: false,
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word()
  }
  @update_attrs %{
    code_name: "NewName",
    description: Faker.Lorem.sentence(),
    dvr_enabled: false,
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word()
  }
  @invalid_attrs %{
    code_name: nil,
    description: nil,
    dvr_enabled: nil,
    epg_id: nil,
    name: nil
  }

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all linear_channels", %{conn: conn} do
      conn = get(conn, linear_channel_path(conn, :index))
      assert html_response(conn, 200) =~ "Tv channels"
    end
  end

  describe "new linear_channel" do
    test "renders form", %{conn: conn} do
      conn = get(conn, linear_channel_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tv channel"
    end
  end

  describe "create linear_channel" do
    test "redirects to show when data is valid", %{conn: conn} do
      create_response =
        post(conn, linear_channel_path(conn, :create), linear_channel: @create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == linear_channel_path(create_response, :show, id)

      show_response = get(conn, linear_channel_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Tv channel"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, linear_channel_path(conn, :create), linear_channel: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tv channel"
    end
  end

  describe "edit linear_channel" do
    setup [:create_linear_channel]

    test "renders form for editing chosen linear_channel", %{
      conn: conn,
      linear_channel: linear_channel
    } do
      conn = get(conn, linear_channel_path(conn, :edit, linear_channel))
      assert html_response(conn, 200) =~ "Edit Tv channel"
    end
  end

  describe "update linear_channel" do
    setup [:create_linear_channel]

    test "redirects when data is valid", %{conn: conn, linear_channel: linear_channel} do
      update_response =
        put(
          conn,
          linear_channel_path(conn, :update, linear_channel),
          linear_channel: @update_attrs
        )

      assert redirected_to(update_response) ==
               linear_channel_path(update_response, :show, linear_channel)

      show_response = get(conn, linear_channel_path(conn, :show, linear_channel))
      assert html_response(show_response, 200) =~ "NewName"
    end

    test "renders errors when data is invalid", %{conn: conn, linear_channel: linear_channel} do
      conn =
        put(
          conn,
          linear_channel_path(conn, :update, linear_channel),
          linear_channel: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Tv channel"
    end
  end

  describe "delete linear_channel" do
    setup [:create_linear_channel]

    test "deletes chosen linear_channel", %{conn: conn, linear_channel: linear_channel} do
      delete_response = delete(conn, linear_channel_path(conn, :delete, linear_channel))
      assert redirected_to(delete_response) == linear_channel_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, linear_channel_path(conn, :show, linear_channel))
      end)
    end
  end

  defp create_linear_channel(_) do
    {:ok, linear_channel} = Factory.insert(:linear_channel)
    {:ok, linear_channel: linear_channel}
  end
end
