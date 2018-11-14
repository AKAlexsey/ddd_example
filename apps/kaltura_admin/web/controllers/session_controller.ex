defmodule KalturaAdmin.SessionController do
  use KalturaAdmin.Web, :controller
  alias KalturaAdmin.Authorization.Guardian, as: GuardImpl
  alias Guardian.Plug, as: GPlug
  import KalturaAdmin.Authorization.Service, only: [authorize: 2, load_user: 1]

  plug :scrub_params, "session" when action in ~w(create)a

  def new(conn, _) do
    current_user = load_user(conn)
    render(conn, "new.html", current_user: current_user)
  end

  def create(conn, %{"session" => %{"email" => email,
    "password" => password}}) do
    current_user = load_user(conn)

    authorize(email, password)
    |> case do
      {:ok, user} ->
        conn
        |> GPlug.sign_in(GuardImpl, user)
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html", current_user: current_user)
    end
  end

  def logout(conn, _) do
    current_user = load_user(conn)

    conn
    |> Guardian.Plug.sign_out(GuardImpl, [])
    |> redirect(to: "/")
  end
end
