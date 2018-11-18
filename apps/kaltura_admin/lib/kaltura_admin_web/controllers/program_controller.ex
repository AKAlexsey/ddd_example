defmodule KalturaAdmin.ProgramController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Content
  alias KalturaAdmin.Content.Program

  def index(conn, _params) do
    programs = Content.list_programs()
    render(conn, "index.html", programs: programs, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Content.change_program(%Program{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
  end

  def create(conn, %{"program" => program_params}) do
    case Content.create_program(program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program created successfully.")
        |> redirect(to: program_path(conn, :show, program))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    program = Content.get_program!(id)
    render(conn, "show.html", program: program, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    program = Content.get_program!(id)
    changeset = Content.change_program(program)

    render(
      conn,
      "edit.html",
      program: program,
      changeset: changeset,
      current_user: load_user(conn)
    )
  end

  def update(conn, %{"id" => id, "program" => program_params}) do
    program = Content.get_program!(id)

    case Content.update_program(program, program_params) do
      {:ok, program} ->
        conn
        |> put_flash(:info, "Program updated successfully.")
        |> redirect(to: program_path(conn, :show, program))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          program: program,
          changeset: changeset,
          current_user: load_user(conn)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    program = Content.get_program!(id)
    {:ok, _program} = Content.delete_program(program)

    conn
    |> put_flash(:info, "Program deleted successfully.")
    |> redirect(to: program_path(conn, :index))
  end
end
