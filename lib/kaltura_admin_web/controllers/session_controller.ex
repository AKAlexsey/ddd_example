defmodule CtiKaltura.SessionController do
  use CtiKalturaWeb, :controller
  use CtiKaltura.KalturaLogger, metadata: [domain: :sessions]

  alias CtiKaltura.Authorization.Guardian, as: GuardImpl
  alias Guardian.Plug, as: GPlug

  plug(:scrub_params, "session" when action in ~w(create)a)

  def new(conn, _) do
    render(conn, "new.html", current_user: load_user(conn))
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    email
    |> authorize(password)
    |> case do
      {:ok, user} ->
        log_info("Successfully logged User with email: #{email}")

        conn
        |> GPlug.sign_in(GuardImpl, user)
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason} ->
        log_info("Failed to login User with email #{email} Invalid email/password combination.")

        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html", current_user: load_user(conn))
    end
  end

  def logout(conn, _) do
    log_info("Logout User with email: #{conn.private.guardian_default_resource.email}")

    conn
    |> Guardian.Plug.sign_out(GuardImpl, [])
    |> redirect(to: "/")
  end
end
