defmodule KalturaAdmin.TvStreamController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Content

  def create(conn, %{"tv_stream" => tv_stream_params}) do
    case Content.create_tv_stream(tv_stream_params) do
      {:ok, %{linear_channel_id: linear_channel_id} = _tv_stream} ->
        linear_channel = Content.get_linear_channel!(linear_channel_id)

        conn
        |> put_flash(:info, "Tv stream created successfully.")
        |> redirect(to: linear_channel_path(conn, :edit, linear_channel))

      {:error, %Ecto.Changeset{changes: %{linear_channel_id: linear_channel_id}} = _changeset} ->
        linear_channel = Content.get_linear_channel!(linear_channel_id, [:tv_streams])

        conn
        |> put_flash(:info, "There is some errors in TvStream")
        |> redirect(to: linear_channel_path(conn, :edit, linear_channel))
    end
  end

  #  TODO возмоно в будущем сделаем редактирование
  #  def edit(conn, %{"id" => id}) do
  #    tv_stream = Content.get_tv_stream!(id)
  #    changeset = Content.change_tv_stream(tv_stream)
  #    render(conn, "edit.html", tv_stream: tv_stream, changeset: changeset)
  #  end
  #
  #  def update(conn, %{"id" => id, "tv_stream" => tv_stream_params}) do
  #    tv_stream = Content.get_tv_stream!(id)
  #
  #    case Content.update_tv_stream(tv_stream, tv_stream_params) do
  #      {:ok, tv_stream} ->
  #        conn
  #        |> put_flash(:info, "Tv stream updated successfully.")
  #        |> redirect(to: tv_stream_path(conn, :show, tv_stream))
  #
  #      {:error, %Ecto.Changeset{} = changeset} ->
  #        render(conn, "edit.html", tv_stream: tv_stream, changeset: changeset)
  #    end
  #  end

  def delete(conn, %{"id" => id}) do
    %{linear_channel: linear_channel} = tv_stream = Content.get_tv_stream!(id, [:linear_channel])
    {:ok, _tv_stream} = Content.delete_tv_stream(tv_stream)

    conn
    |> put_flash(:info, "Tv stream deleted successfully.")
    |> redirect(to: linear_channel_path(conn, :edit, linear_channel))
  end
end
