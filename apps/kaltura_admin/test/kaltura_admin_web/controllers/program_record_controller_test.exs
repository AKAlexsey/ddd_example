defmodule KalturaAdminWeb.ProgramRecordControllerTest do
  use KalturaAdmin.ConnCase

  @create_attrs %{protocol: :HLS, path: "/content", status: :planned}
  @update_attrs %{protocol: :HLS, path: "/content", status: :planned}
  @invalid_attrs %{protocol: nil, path: nil, status: nil}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all program_records", %{conn: conn} do
      conn = get(conn, program_record_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Program records"
    end
  end

  describe "new program_record" do
    test "renders form", %{conn: conn} do
      conn = get(conn, program_record_path(conn, :new))
      assert html_response(conn, 200) =~ "New Program record"
    end
  end

  describe "create program_record" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, server} = Factory.insert(:server)
      {:ok, program} = Factory.insert(:program)
      create_attrs = Map.merge(@create_attrs, %{server_id: server.id, program_id: program.id})

      create_response =
        post(conn, program_record_path(conn, :create), program_record: create_attrs)

      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == program_record_path(create_response, :show, id)

      show_response = get(conn, program_record_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Program record"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, program_record_path(conn, :create), program_record: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Program record"
    end
  end

  describe "edit program_record" do
    setup [:create_program_record]

    test "renders form for editing chosen program_record", %{
      conn: conn,
      program_record: program_record
    } do
      conn = get(conn, program_record_path(conn, :edit, program_record))
      assert html_response(conn, 200) =~ "Edit Program record"
    end
  end

  describe "update program_record" do
    setup [:create_program_record]

    test "redirects when data is valid", %{conn: conn, program_record: program_record} do
      update_response =
        put(
          conn,
          program_record_path(conn, :update, program_record),
          program_record: @update_attrs
        )

      assert redirected_to(update_response) ==
               program_record_path(update_response, :show, program_record)

      show_response = get(conn, program_record_path(conn, :show, program_record))
      assert html_response(show_response, 200) =~ "/content"
    end

    test "renders errors when data is invalid", %{conn: conn, program_record: program_record} do
      conn =
        put(
          conn,
          program_record_path(conn, :update, program_record),
          program_record: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Program record"
    end
  end

  describe "delete program_record" do
    setup [:create_program_record]

    test "deletes chosen program_record", %{conn: conn, program_record: program_record} do
      delete_response = delete(conn, program_record_path(conn, :delete, program_record))
      assert redirected_to(delete_response) == program_record_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, program_record_path(conn, :show, program_record))
      end)
    end
  end

  defp create_program_record(_) do
    {:ok, program_record} = Factory.insert(:program_record)
    {:ok, program_record: program_record}
  end
end
