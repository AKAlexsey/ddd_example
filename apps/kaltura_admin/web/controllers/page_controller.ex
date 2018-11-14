defmodule KalturaAdmin.PageController do
  use KalturaAdmin.Web, :controller
  import KalturaAdmin.Authorization.Service, only: [load_user: 1]

  def index(conn, _params) do
    current_user = load_user(conn)
    render(conn, "index.html", current_user: current_user)
  end
end
