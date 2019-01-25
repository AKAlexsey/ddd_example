defmodule KalturaAdmin.ServerController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.{Repo, Servers}
  alias KalturaAdmin.Servers.Server

  def index(conn, _params) do
    servers = Servers.list_servers([:server_groups, :streaming_groups])
    render(conn, "index.html", servers: servers, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Servers.change_server(%Server{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn), server_id: nil)
  end

  def create(conn, %{"server" => server_params}) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          server_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    server =
      id
      |> Servers.get_server!()
      |> Repo.preload([:server_groups, :streaming_groups])

    render(conn, "show.html", server: server, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    server =
      id
      |> Servers.get_server!()
      |> Repo.preload([:server_groups, :streaming_groups])

    changeset = Servers.change_server(server)

    render(
      conn,
      "edit.html",
      server: server,
      changeset: changeset,
      current_user: load_user(conn),
      server_id: id
    )
  end

  def update(conn, %{"id" => id, "server" => server_params}) do
    server = Servers.get_server!(id)

    case Servers.update_server(server, server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          server: server,
          changeset: changeset,
          current_user: load_user(conn),
          server_id: id
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Servers.get_server!(id)
    {:ok, _server} = Servers.delete_server(server)

    conn
    |> put_flash(:info, "Server deleted successfully.")
    |> redirect(to: server_path(conn, :index))
  end
end
