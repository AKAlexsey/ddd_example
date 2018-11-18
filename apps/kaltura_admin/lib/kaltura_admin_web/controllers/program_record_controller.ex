defmodule KalturaAdmin.ProgramRecordController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Content
  alias KalturaAdmin.Content.ProgramRecord

  def index(conn, _params) do
    program_records = Content.list_program_records()
    render(conn, "index.html", program_records: program_records, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Content.change_program_record(%ProgramRecord{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
  end

  def create(conn, %{"program_record" => program_record_params}) do
    case Content.create_program_record(program_record_params) do
      {:ok, program_record} ->
        conn
        |> put_flash(:info, "Program record created successfully.")
        |> redirect(to: program_record_path(conn, :show, program_record))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    render(conn, "show.html", program_record: program_record, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    changeset = Content.change_program_record(program_record)

    render(
      conn,
      "edit.html",
      program_record: program_record,
      changeset: changeset,
      current_user: load_user(conn)
    )
  end

  def update(conn, %{"id" => id, "program_record" => program_record_params}) do
    program_record = Content.get_program_record!(id)

    case Content.update_program_record(program_record, program_record_params) do
      {:ok, program_record} ->
        conn
        |> put_flash(:info, "Program record updated successfully.")
        |> redirect(to: program_record_path(conn, :show, program_record))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          program_record: program_record,
          changeset: changeset,
          current_user: load_user(conn)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    {:ok, _program_record} = Content.delete_program_record(program_record)

    conn
    |> put_flash(:info, "Program record deleted successfully.")
    |> redirect(to: program_record_path(conn, :index))
  end
end
