defmodule CtiKaltura.LinearChannelController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.{Content, ErrorHelpers}
  alias CtiKaltura.Content.{LinearChannel, TvStream}

  def index(conn, _params) do
    linear_channels = Content.list_linear_channels([:server_group])
    render(conn, "index.html", linear_channels: linear_channels, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Content.change_linear_channel(%LinearChannel{})

    render(
      conn,
      "new.html",
      changeset: changeset,
      current_user: load_user(conn),
      linear_channel_id: nil
    )
  end

  def create(conn, %{"linear_channel" => linear_channel_params}) do
    case Content.create_linear_channel(linear_channel_params) do
      {:ok, linear_channel} ->
        conn
        |> put_flash(:info, "Linear channel created successfully.")
        |> redirect(to: linear_channel_path(conn, :show, linear_channel))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          linear_channel_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    linear_channel =
      id
      |> Content.get_linear_channel!()
      |> Repo.preload(:server_group)

    render(conn, "show.html", linear_channel: linear_channel, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    linear_channel = Content.get_linear_channel!(id, [:tv_streams])
    changeset = Content.change_linear_channel(linear_channel)

    render(
      conn,
      "edit.html",
      linear_channel: linear_channel,
      changeset: changeset,
      current_user: load_user(conn),
      new_tv_stream: TvStream.changeset(%TvStream{}, %{linear_channel_id: id})
    )
  end

  def update(conn, %{"id" => id, "linear_channel" => linear_channel_params}) do
    linear_channel = Content.get_linear_channel!(id, [:tv_streams])

    case Content.update_linear_channel(linear_channel, linear_channel_params) do
      {:ok, linear_channel} ->
        conn
        |> put_flash(:info, "Linear channel updated successfully.")
        |> redirect(to: linear_channel_path(conn, :show, linear_channel))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          linear_channel: linear_channel,
          changeset: changeset,
          current_user: load_user(conn),
          linear_channel_id: id,
          new_tv_stream: TvStream.changeset(%TvStream{}, %{linear_channel_id: id})
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    linear_channel = Content.get_linear_channel!(id)

    case Content.delete_linear_channel(linear_channel) do
      {:ok, _linear_channel} ->
        conn
        |> put_flash(:info, "Linear channel deleted successfully.")
        |> redirect(to: linear_channel_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, ErrorHelpers.prepare_error_message(changeset))
        |> redirect(to: linear_channel_path(conn, :index))
    end
  end
end
