defmodule KalturaAdmin.ChannelController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Channel

  def index(conn, _params) do
    channels = Repo.all(Channel)
    render(conn, "index.html", channels: channels, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Channel.changeset(%Channel{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
  end

  def create(conn, %{"channel" => channel_params}) do
    changeset = Channel.changeset(%Channel{}, channel_params)

    case Repo.insert(changeset) do
      {:ok, channel} ->
        conn
        |> put_flash(:info, "Channel created successfully.")
        |> redirect(to: channel_path(conn, :show, channel))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)
    render(conn, "show.html", channel: channel, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)
    changeset = Channel.changeset(channel)

    render(
      conn,
      "edit.html",
      channel: channel,
      changeset: changeset,
      current_user: load_user(conn)
    )
  end

  def update(conn, %{"id" => id, "channel" => channel_params}) do
    channel = Repo.get!(Channel, id)
    changeset = Channel.changeset(channel, channel_params)

    case Repo.update(changeset) do
      {:ok, channel} ->
        %{"name" => name, "url" => url} = channel_params

        Application.get_env(:kaltura_admin, :channel_handler).handle(:channel_updated, %{
          name: name,
          url: url
        })

        conn
        |> put_flash(:info, "Channel updated successfully.")
        |> redirect(to: channel_path(conn, :show, channel))

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          channel: channel,
          changeset: changeset,
          current_user: load_user(conn)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    channel = Repo.get!(Channel, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(channel)

    conn
    |> put_flash(:info, "Channel deleted successfully.")
    |> redirect(to: channel_path(conn, :index))
  end
end
