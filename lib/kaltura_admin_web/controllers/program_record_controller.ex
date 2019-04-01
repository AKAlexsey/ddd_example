defmodule CtiKaltura.ProgramRecordController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.Content
  alias CtiKaltura.Content.ProgramRecord

  def index(conn, _params) do
    program_records = Content.list_program_records()
    render(conn, "index.html", program_records: program_records, current_user: load_user(conn))
  end

  def new(conn, %{"program_id" => program_id}) do
    changeset = Content.change_program_record(%ProgramRecord{:program_id => program_id})
    program = Content.get_program!(program_id)

    render(
      conn,
      "new.html",
      changeset: changeset,
      current_user: load_user(conn),
      program: program
    )
  end

  def create(conn, %{"program_record" => program_record_params}) do
    case Content.create_program_record(program_record_params) do
      {:ok, program_record} ->
        conn
        |> put_flash(:info, "Program record created successfully.")
        |> redirect(to: program_record_path(conn, :show, program_record))

      {:error, %Ecto.Changeset{} = changeset} ->
        program = Content.get_program!(program_record_params["program_id"])

        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          program: program
        )
    end
  end

  def show(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    program = Content.get_program!(program_record.program_id)

    render(
      conn,
      "show.html",
      program_record: program_record,
      current_user: load_user(conn),
      program: program
    )
  end

  def edit(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    program = Content.get_program!(program_record.program_id)
    changeset = Content.change_program_record(program_record)

    render(
      conn,
      "edit.html",
      program_record: program_record,
      changeset: changeset,
      current_user: load_user(conn),
      program: program
    )
  end

  def update(conn, %{"id" => id, "program_record" => program_record_params}) do
    program_record = Content.get_program_record!(id)

    case Content.update_program_record(program_record, program_record_params) do
      {:ok, program_record} ->
        conn
        |> put_flash(:info, "Program record updated successfully.")
        |> redirect(to: program_record_path(conn, :show, program_record))

      {:error, %Ecto.Changeset{data: %{program_id: program_id}} = changeset} ->
        program = Content.get_program!(program_id)

        render(
          conn,
          "edit.html",
          program_record: program_record,
          changeset: changeset,
          current_user: load_user(conn),
          program: program
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    program_record = Content.get_program_record!(id)
    program = Content.get_program!(program_record.program_id)
    {:ok, _program_record} = Content.delete_program_record(program_record)

    conn
    |> put_flash(:info, "Program record deleted successfully.")
    |> redirect(to: program_path(conn, :show, program))
  end
end
