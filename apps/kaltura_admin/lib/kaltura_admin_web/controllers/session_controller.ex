defmodule KalturaAdmin.SessionController do
  use KalturaAdminWeb, :controller
  alias Guardian.Plug, as: GPlug
  alias KalturaAdmin.Authorization.Guardian, as: GuardImpl

  plug(:scrub_params, "session" when action in ~w(create)a)

  def new(conn, _) do
    render(conn, "new.html", current_user: load_user(conn))
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    email
    |> authorize(password)
    |> case do
      {:ok, user} ->
        conn
        |> GPlug.sign_in(GuardImpl, user)
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html", current_user: load_user(conn))
    end
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out(GuardImpl, [])
    |> redirect(to: "/")
  end
end
