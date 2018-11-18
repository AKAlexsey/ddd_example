defmodule KalturaAdminWeb.ProgramRecordControllerTest do
  use KalturaAdminWeb.ConnCase

  alias KalturaAdmin.Content

  @create_attrs %{codec: 42, path: "some path", status: 42}
  @update_attrs %{codec: 43, path: "some updated path", status: 43}
  @invalid_attrs %{codec: nil, path: nil, status: nil}

  def fixture(:program_record) do
    {:ok, program_record} = Content.create_program_record(@create_attrs)
    program_record
  end

  describe "index" do
    test "lists all program_records", %{conn: conn} do
      conn = get(conn, Routes.program_record_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Program records"
    end
  end

  describe "new program_record" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.program_record_path(conn, :new))
      assert html_response(conn, 200) =~ "New Program record"
    end
  end

  describe "create program_record" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.program_record_path(conn, :create), program_record: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.program_record_path(conn, :show, id)

      conn = get(conn, Routes.program_record_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Program record"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.program_record_path(conn, :create), program_record: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Program record"
    end
  end

  describe "edit program_record" do
    setup [:create_program_record]

    test "renders form for editing chosen program_record", %{
      conn: conn,
      program_record: program_record
    } do
      conn = get(conn, Routes.program_record_path(conn, :edit, program_record))
      assert html_response(conn, 200) =~ "Edit Program record"
    end
  end

  describe "update program_record" do
    setup [:create_program_record]

    test "redirects when data is valid", %{conn: conn, program_record: program_record} do
      conn =
        put(
          conn,
          Routes.program_record_path(conn, :update, program_record),
          program_record: @update_attrs
        )

      assert redirected_to(conn) == Routes.program_record_path(conn, :show, program_record)

      conn = get(conn, Routes.program_record_path(conn, :show, program_record))
      assert html_response(conn, 200) =~ "some updated path"
    end

    test "renders errors when data is invalid", %{conn: conn, program_record: program_record} do
      conn =
        put(
          conn,
          Routes.program_record_path(conn, :update, program_record),
          program_record: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Program record"
    end
  end

  describe "delete program_record" do
    setup [:create_program_record]

    test "deletes chosen program_record", %{conn: conn, program_record: program_record} do
      conn = delete(conn, Routes.program_record_path(conn, :delete, program_record))
      assert redirected_to(conn) == Routes.program_record_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.program_record_path(conn, :show, program_record))
      end)
    end
  end

  defp create_program_record(_) do
    program_record = fixture(:program_record)
    {:ok, program_record: program_record}
  end
end
