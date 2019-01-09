defmodule KalturaAdmin.SubnetController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.{Area, Repo}
  alias KalturaAdmin.Area.Subnet

  def index(conn, _params) do
    subnetss = Area.list_subnetss(:region)
    render(conn, "index.html", subnetss: subnetss, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Area.change_subnet(%Subnet{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
  end

  def create(conn, %{"subnet" => subnet_params}) do
    case Area.create_subnet(subnet_params) do
      {:ok, subnet} ->
        conn
        |> put_flash(:info, "Subnet created successfully.")
        |> redirect(to: subnet_path(conn, :show, subnet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    subnet = id
      |> Area.get_subnet!()
      |> Repo.preload(:region)

    render(conn, "show.html", subnet: subnet, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    subnet = id
      |> Area.get_subnet!()
      |> Repo.preload(:region)

    changeset = Area.change_subnet(subnet)
    render(conn, "edit.html", subnet: subnet, changeset: changeset, current_user: load_user(conn))
  end

  def update(conn, %{"id" => id, "subnet" => subnet_params}) do
    subnet = Area.get_subnet!(id)

    case Area.update_subnet(subnet, subnet_params) do
      {:ok, subnet} ->
        conn
        |> put_flash(:info, "Subnet updated successfully.")
        |> redirect(to: subnet_path(conn, :show, subnet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          subnet: subnet,
          changeset: changeset,
          current_user: load_user(conn)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    subnet = Area.get_subnet!(id)
    {:ok, _subnet} = Area.delete_subnet(subnet)

    conn
    |> put_flash(:info, "Subnet deleted successfully.")
    |> redirect(to: subnet_path(conn, :index))
  end
end
