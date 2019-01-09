defmodule KalturaAdmin.TvStreamController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Content
  alias KalturaAdmin.Content.TvStream

  def index(conn, _params) do
    tv_streams = Content.list_tv_streams([:server_groups])
    render(conn, "index.html", tv_streams: tv_streams, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Content.change_tv_stream(%TvStream{})

    render(
      conn,
      "new.html",
      changeset: changeset,
      current_user: load_user(conn),
      tv_stream_id: nil
    )
  end

  def create(conn, %{"tv_stream" => tv_stream_params}) do
    case Content.create_tv_stream(tv_stream_params) do
      {:ok, tv_stream} ->
        conn
        |> put_flash(:info, "Tv stream created successfully.")
        |> redirect(to: tv_stream_path(conn, :show, tv_stream))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          tv_stream_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    tv_stream =
      id
      |> Content.get_tv_stream!()
      |> Repo.preload(:server_groups)

    render(conn, "show.html", tv_stream: tv_stream, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    tv_stream = Content.get_tv_stream!(id)
    changeset = Content.change_tv_stream(tv_stream)

    render(
      conn,
      "edit.html",
      tv_stream: tv_stream,
      changeset: changeset,
      current_user: load_user(conn),
      tv_stream_id: id
    )
  end

  def update(conn, %{"id" => id, "tv_stream" => tv_stream_params}) do
    tv_stream = Content.get_tv_stream!(id)

    case Content.update_tv_stream(tv_stream, tv_stream_params) do
      {:ok, tv_stream} ->
        conn
        |> put_flash(:info, "Tv stream updated successfully.")
        |> redirect(to: tv_stream_path(conn, :show, tv_stream))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          tv_stream: tv_stream,
          changeset: changeset,
          current_user: load_user(conn),
          tv_stream_id: id
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    tv_stream = Content.get_tv_stream!(id)
    {:ok, _tv_stream} = Content.delete_tv_stream(tv_stream)

    conn
    |> put_flash(:info, "Tv stream deleted successfully.")
    |> redirect(to: tv_stream_path(conn, :index))
  end
end
