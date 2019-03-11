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
      {:ok, program} = Factory.insert(:program)
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      {:ok, other_program} = Factory.insert(:program)

      {:ok, other_program_record} =
        Factory.insert(:program_record, %{program_id: other_program.id})

      response_conn = get(conn, program_path(conn, :show, program))

      assert html_response(response_conn, 200) =~ "Program records"
      assert html_response(response_conn, 200) =~ program_record.path
      refute html_response(response_conn, 200) =~ other_program_record.path

      response_conn = get(conn, program_path(conn, :show, other_program))

      assert html_response(response_conn, 200) =~ "Program records"
      refute html_response(response_conn, 200) =~ program_record.path
      assert html_response(response_conn, 200) =~ other_program_record.path
    end
  end

  describe "new program_record" do
    test "renders form", %{conn: conn} do
      {:ok, program} = Factory.insert(:program)
      conn = get(conn, program_record_path(conn, :new, %{"program_id" => program.id}))
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
      assert html_response(show_response, 200) =~ "Program record"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, program} = Factory.insert(:program)
      invalid_attrs = Map.put(@invalid_attrs, :program_id, program.id)

      conn = post(conn, program_record_path(conn, :create), program_record: invalid_attrs)
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
      program_record = Repo.preload(program_record, :program)
      program = program_record.program

      delete_response = delete(conn, program_record_path(conn, :delete, program_record))
      assert redirected_to(delete_response) == program_path(delete_response, :show, program)

      assert_error_sent(404, fn ->
        get(conn, program_record_path(conn, :show, program_record, %{"program_id" => program.id}))
      end)
    end
  end

  defp create_program_record(_) do
    {:ok, program_record} = Factory.insert(:program_record)
    {:ok, program_record: program_record}
  end
end
