defmodule KalturaAdmin.PageController do
  use KalturaAdminWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_user: load_user(conn))
  end
end
