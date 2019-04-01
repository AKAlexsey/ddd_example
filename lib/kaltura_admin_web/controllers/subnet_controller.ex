defmodule CtiKaltura.SubnetController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.{Area, Repo}
  alias CtiKaltura.Area.Subnet

  def index(conn, _params) do
    subnets = Area.list_subnets(:region)
    render(conn, "index.html", subnets: subnets, current_user: load_user(conn))
  end

  def new(conn, %{"region_id" => region_id}) do
    changeset = Area.change_subnet(%Subnet{:region_id => region_id})

    region = Area.get_region!(region_id)

    render(conn, "new.html", changeset: changeset, current_user: load_user(conn), region: region)
  end

  def create(conn, %{"subnet" => subnet_params}) do
    case Area.create_subnet(subnet_params) do
      {:ok, subnet} ->
        conn
        |> put_flash(:info, "Subnet created successfully.")
        |> redirect(to: subnet_path(conn, :show, subnet))

      {:error, %Ecto.Changeset{} = changeset} ->
        region = Area.get_region!(subnet_params["region_id"])

        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          region: region
        )
    end
  end

  def show(conn, %{"id" => id}) do
    subnet =
      id
      |> Area.get_subnet!()
      |> Repo.preload(:region)

    region = subnet.region_id |> Area.get_region!()

    render(conn, "show.html", subnet: subnet, current_user: load_user(conn), region: region)
  end

  def edit(conn, %{"id" => id}) do
    subnet = id |> Area.get_subnet!() |> Repo.preload(:region)

    changeset = Area.change_subnet(subnet)
    render(conn, "edit.html", subnet: subnet, changeset: changeset, current_user: load_user(conn))
  end

  def update(conn, %{"id" => id, "subnet" => subnet_params}) do
    subnet = id |> Area.get_subnet!() |> Repo.preload(:region)

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
    region = subnet.region_id |> Area.get_region!()
    {:ok, _subnet} = Area.delete_subnet(subnet)

    conn
    |> put_flash(:info, "Subnet deleted successfully.")
    |> redirect(to: region_path(conn, :show, region))
  end
end
