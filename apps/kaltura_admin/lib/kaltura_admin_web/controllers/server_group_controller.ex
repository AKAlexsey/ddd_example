defmodule KalturaAdmin.ServerGroupController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Servers
  alias KalturaAdmin.Servers.ServerGroup

  def index(conn, _params) do
    server_groups = Servers.list_server_groups([:regions, :tv_streams, :servers])
    render(conn, "index.html", server_groups: server_groups, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Servers.change_server_group(%ServerGroup{})

    render(
      conn,
      "new.html",
      changeset: changeset,
      current_user: load_user(conn),
      server_group_id: nil
    )
  end

  def create(conn, %{"server_group" => server_group_params}) do
    case Servers.create_server_group(server_group_params) do
      {:ok, server_group} ->
        conn
        |> put_flash(:info, "Server group created successfully.")
        |> redirect(to: server_group_path(conn, :show, server_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          server_group_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    server_group =
      Servers.get_server_group!(id)
      |> Repo.preload([:regions, :tv_streams, :servers])

    render(conn, "show.html", server_group: server_group, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    server_group = Servers.get_server_group!(id)
    changeset = Servers.change_server_group(server_group)

    render(
      conn,
      "edit.html",
      server_group: server_group,
      changeset: changeset,
      current_user: load_user(conn),
      server_group_id: id
    )
  end

  def update(conn, %{"id" => id, "server_group" => server_group_params}) do
    server_group = Servers.get_server_group!(id)

    case Servers.update_server_group(server_group, server_group_params) do
      {:ok, server_group} ->
        conn
        |> put_flash(:info, "Server group updated successfully.")
        |> redirect(to: server_group_path(conn, :show, server_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          server_group: server_group,
          changeset: changeset,
          current_user: load_user(conn),
          server_group_id: id
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    server_group = Servers.get_server_group!(id)
    {:ok, _server_group} = Servers.delete_server_group(server_group)

    conn
    |> put_flash(:info, "Server group deleted successfully.")
    |> redirect(to: server_group_path(conn, :index))
  end
end
