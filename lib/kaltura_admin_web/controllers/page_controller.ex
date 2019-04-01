defmodule CtiKaltura.PageController do
  use CtiKalturaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_user: load_user(conn))
  end
end
