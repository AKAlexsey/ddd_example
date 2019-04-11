defmodule CtiKaltura.UserController do
  use CtiKalturaWeb, :controller

  alias CtiKaltura.Users

  def index(conn, _params) do
    logged_user = load_user(conn)
    users = Users.get_available_users_with_permissions_check(logged_user)
    render(conn, "index.html", users: users, current_user: logged_user)
  end

  def new(conn, _params) do
    logged_user = load_user(conn)

    with true <- Users.has_permissions_to_create?(logged_user),
         changeset <- Users.changeset() do
      render(conn, "new.html", changeset: changeset, current_user: logged_user)
    else
      _ ->
        conn
        |> put_flash(:error, "You have no permissions to create user!")
        |> redirect(to: user_path(conn, :index))
    end
  end

  def create(conn, %{"user" => user_params}) do
    logged_user = load_user(conn)

    case Users.create_with_permissions_check(logged_user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, :forbidden} ->
        conn
        |> put_flash(:error, "You have no permissions to create user!")
        |> redirect(to: user_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, current_user: logged_user)
    end
  end

  def show(conn, %{"id" => id}) do
    logged_user = load_user(conn)

    case Users.get_user_with_permissions_check(logged_user, id) do
      {:ok, nil} ->
        conn
        |> put_flash(:error, "User not found!")
        |> redirect(to: user_path(conn, :index))

      {:ok, user} ->
        conn
        |> render("show.html", user: user, current_user: load_user(conn))

      {:error, :forbidden} ->
        conn
        |> put_flash(:error, "You have no permissions to view this user info!")
        |> redirect(to: user_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    logged_user = load_user(conn)

    with true <- Users.has_permissions_to_edit?(logged_user, id),
         changeset <- Users.changeset(id) do
      conn
      |> render(
        "edit.html",
        user: changeset.data,
        changeset: changeset,
        current_user: logged_user,
        can_change_role: Users.can_change_role?(logged_user, id)
      )
    else
      _ ->
        conn
        |> put_flash(:error, "You have no permissions to edit this user!")
        |> redirect(to: user_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    logged_user = load_user(conn)

    case Users.update_with_permissions_check(logged_user, user_params, id) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, :forbidden} ->
        conn
        |> put_flash(:error, "You have no permissions to edit this user!")
        |> redirect(to: user_path(conn, :index))

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          user: changeset.data,
          changeset: changeset,
          current_user: logged_user,
          can_change_role: Users.can_change_role?(logged_user, id)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    logged_user = load_user(conn)

    case Users.delete_with_permissions_check(logged_user, id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))

      {:error, :forbidden} ->
        conn
        |> put_flash(:error, "You have no permissions to delete this user!")
        |> redirect(to: user_path(conn, :index))
    end
  end
end
