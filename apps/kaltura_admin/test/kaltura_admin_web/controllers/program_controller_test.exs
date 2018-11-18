defmodule KalturaAdminWeb.ProgramControllerTest do
  use KalturaAdminWeb.ConnCase

  alias KalturaAdmin.Content

  @create_attrs %{
    end_datetime: ~N[2010-04-17 14:00:00],
    epg_id: "some epg_id",
    name: "some name",
    start_datetime: ~N[2010-04-17 14:00:00]
  }
  @update_attrs %{
    end_datetime: ~N[2011-05-18 15:01:01],
    epg_id: "some updated epg_id",
    name: "some updated name",
    start_datetime: ~N[2011-05-18 15:01:01]
  }
  @invalid_attrs %{end_datetime: nil, epg_id: nil, name: nil, start_datetime: nil}

  def fixture(:program) do
    {:ok, program} = Content.create_program(@create_attrs)
    program
  end

  describe "index" do
    test "lists all programs", %{conn: conn} do
      conn = get(conn, Routes.program_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Programs"
    end
  end

  describe "new program" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.program_path(conn, :new))
      assert html_response(conn, 200) =~ "New Program"
    end
  end

  describe "create program" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.program_path(conn, :create), program: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.program_path(conn, :show, id)

      conn = get(conn, Routes.program_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Program"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.program_path(conn, :create), program: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Program"
    end
  end

  describe "edit program" do
    setup [:create_program]

    test "renders form for editing chosen program", %{conn: conn, program: program} do
      conn = get(conn, Routes.program_path(conn, :edit, program))
      assert html_response(conn, 200) =~ "Edit Program"
    end
  end

  describe "update program" do
    setup [:create_program]

    test "redirects when data is valid", %{conn: conn, program: program} do
      conn = put(conn, Routes.program_path(conn, :update, program), program: @update_attrs)
      assert redirected_to(conn) == Routes.program_path(conn, :show, program)

      conn = get(conn, Routes.program_path(conn, :show, program))
      assert html_response(conn, 200) =~ "some updated epg_id"
    end

    test "renders errors when data is invalid", %{conn: conn, program: program} do
      conn = put(conn, Routes.program_path(conn, :update, program), program: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Program"
    end
  end

  describe "delete program" do
    setup [:create_program]

    test "deletes chosen program", %{conn: conn, program: program} do
      conn = delete(conn, Routes.program_path(conn, :delete, program))
      assert redirected_to(conn) == Routes.program_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.program_path(conn, :show, program))
      end)
    end
  end

  defp create_program(_) do
    program = fixture(:program)
    {:ok, program: program}
  end
end
