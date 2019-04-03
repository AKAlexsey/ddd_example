defmodule CtiKaltura.UserController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.User

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users, current_user: load_user(conn))
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: load_user(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user, current_user: load_user(conn))
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset, current_user: load_user(conn))
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, current_user: load_user(conn))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    logined_user = load_user(conn)

    if user.id == logined_user.id do
      conn
      |> put_flash(:error, "You cannot remove yourself!")
      |> redirect(to: user_path(conn, :index))
    else
      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(user)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: user_path(conn, :index))
    end
  end
end
