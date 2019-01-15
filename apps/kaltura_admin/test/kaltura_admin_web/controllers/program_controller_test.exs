defmodule KalturaAdminWeb.ProgramControllerTest do
  use KalturaAdmin.ConnCase

  @create_attrs %{
    end_datetime: ~N[2010-04-17 14:00:00],
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word(),
    start_datetime: ~N[2010-04-17 14:00:00]
  }
  @update_attrs %{
    end_datetime: ~N[2011-05-18 15:01:01],
    epg_id: Faker.Lorem.word(),
    name: "New name",
    start_datetime: ~N[2011-05-18 15:01:01]
  }
  @invalid_attrs %{end_datetime: nil, epg_id: nil, name: nil, start_datetime: nil}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user)}
  end

  describe "index" do
    test "lists all programs", %{conn: conn} do
      conn = get(conn, program_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Programs"
    end
  end

  describe "new program" do
    test "renders form", %{conn: conn} do
      conn = get(conn, program_path(conn, :new))
      assert html_response(conn, 200) =~ "New Program"
    end
  end

  describe "create program" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, tv_stream} = Factory.insert(:tv_stream)
      create_attrs = Map.merge(@create_attrs, %{tv_stream_id: tv_stream.id})
      create_response = post(conn, program_path(conn, :create), program: create_attrs)
      assert %{id: id} = redirected_params(create_response)
      assert redirected_to(create_response) == program_path(create_response, :show, id)

      show_response = get(conn, program_path(conn, :show, id))
      assert html_response(show_response, 200) =~ "Show Program"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, program_path(conn, :create), program: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Program"
    end
  end

  describe "edit program" do
    setup [:create_program]

    test "renders form for editing chosen program", %{conn: conn, program: program} do
      conn = get(conn, program_path(conn, :edit, program))
      assert html_response(conn, 200) =~ "Edit Program"
    end
  end

  describe "update program" do
    setup [:create_program]

    test "redirects when data is valid", %{conn: conn, program: program} do
      update_response = put(conn, program_path(conn, :update, program), program: @update_attrs)
      assert redirected_to(update_response) == program_path(update_response, :show, program)

      show_response = get(conn, program_path(conn, :show, program))
      assert html_response(show_response, 200) =~ "New name"
    end

    test "renders errors when data is invalid", %{conn: conn, program: program} do
      conn = put(conn, program_path(conn, :update, program), program: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Program"
    end
  end

  describe "delete program" do
    setup [:create_program]

    test "deletes chosen program", %{conn: conn, program: program} do
      delete_response = delete(conn, program_path(conn, :delete, program))
      assert redirected_to(delete_response) == program_path(delete_response, :index)

      assert_error_sent(404, fn ->
        get(conn, program_path(conn, :show, program))
      end)
    end
  end

  defp create_program(_) do
    {:ok, program} = Factory.insert(:program, @create_attrs)
    {:ok, program: program}
  end
end
