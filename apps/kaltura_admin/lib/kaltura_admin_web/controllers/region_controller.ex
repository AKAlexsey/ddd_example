defmodule KalturaAdmin.RegionController do
  use KalturaAdminWeb, :controller

  alias KalturaAdmin.Area
  alias KalturaAdmin.Area.Region

  def index(conn, _params) do
    regions = Area.list_regions(:server_groups)
    render(conn, "index.html", regions: regions, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = Area.change_region(%Region{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn), region_id: nil)
  end

  def create(conn, %{"region" => region_params}) do
    case Area.create_region(region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region created successfully.")
        |> redirect(to: region_path(conn, :show, region))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          current_user: load_user(conn),
          region_id: nil
        )
    end
  end

  def show(conn, %{"id" => id}) do
    region =
      Area.get_region!(id)
      |> Repo.preload(:server_groups)

    render(conn, "show.html", region: region, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    region = Area.get_region!(id)
    changeset = Area.change_region(region)

    render(
      conn,
      "edit.html",
      region: region,
      changeset: changeset,
      current_user: load_user(conn),
      region_id: id
    )
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    region = Area.get_region!(id)

    case Area.update_region(region, region_params) do
      {:ok, region} ->
        conn
        |> put_flash(:info, "Region updated successfully.")
        |> redirect(to: region_path(conn, :show, region))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          region: region,
          changeset: changeset,
          current_user: load_user(conn),
          region_id: id
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Area.get_region!(id)
    {:ok, _region} = Area.delete_region(region)

    conn
    |> put_flash(:info, "Region deleted successfully.")
    |> redirect(to: region_path(conn, :index))
  end
end
