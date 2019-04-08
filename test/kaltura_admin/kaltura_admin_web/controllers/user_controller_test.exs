defmodule CtiKaltura.UserControllerTest do
  use CtiKaltura.ConnCase

  alias CtiKaltura.User

  @valid_attrs %{
    email: Faker.Internet.email(),
    first_name: Faker.Name.first_name(),
    last_name: Faker.Name.last_name(),
    password: "qweasd123",
    role: "MANAGER"
  }
  @invalid_attrs %{}

  describe "common behaviour : " do
    setup tags do
      {:ok, user} = Factory.insert(:admin)
      {:ok, conn: authorize(tags[:conn], user), logged_user: user}
    end

    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end

    test "renders form for new resources", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end

    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @valid_attrs)
      user = Repo.get_by!(User, %{email: Map.get(@valid_attrs, :email)})
      assert redirected_to(conn) == user_path(conn, :show, user.id)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end

    test "shows chosen resource", %{conn: conn} do
      user = Repo.insert!(%User{})
      conn = get(conn, user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "User"
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      conn = get(conn, user_path(conn, :show, -1))
      assert redirected_to(conn) == user_path(conn, :index)
      assert conn.private.phoenix_flash == %{"error" => "User not found!"}
    end

    test "renders form for editing chosen resource", %{conn: conn} do
      user = Repo.insert!(%User{})
      conn = get(conn, user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      user = Repo.insert!(%User{})
      conn = put(conn, user_path(conn, :update, user), user: @valid_attrs)
      assert redirected_to(conn) == user_path(conn, :show, user)
      assert Repo.get_by(User, %{email: Map.get(@valid_attrs, :email)})
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      user = Repo.insert!(%User{})
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe " behaviour with restrictions (operations from ADMIN role) : " do
    setup tags do
      {:ok, logged_user} = Factory.insert(:admin)
      {:ok, user} = Factory.insert(:user)
      {:ok, conn: authorize(tags[:conn], logged_user), logged_user: logged_user, user: user}
    end

    test "operation show users table", %{conn: conn, logged_user: logged_user, user: user} do
      conn = get(conn, user_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Users"
      assert response =~ logged_user.email
      assert response =~ user.email
    end

    test "operation new user", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User:"
    end

    test "operation create user", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @valid_attrs)
      user = Repo.get_by!(User, %{email: Map.get(@valid_attrs, :email)})
      assert redirected_to(conn) == user_path(conn, :show, user.id)
      assert conn.private.phoenix_flash == %{"info" => "User created successfully."}
    end

    test "operation show user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = get(conn, user_path(conn, :show, logged_user.id))
      response = html_response(conn, 200)
      assert response =~ "User ##{logged_user.id}"
    end

    test "operation show user (another)", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :show, user.id))
      response = html_response(conn, 200)
      assert response =~ "User ##{user.id}"
    end

    test "operation edit user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = get(conn, user_path(conn, :edit, logged_user.id))
      response = html_response(conn, 200)
      assert response =~ "Edit User:"
    end

    test "operation edit user (another)", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user.id))
      response = html_response(conn, 200)
      assert response =~ "Edit User:"
    end

    test "operation update user (yourself)", %{conn: conn, logged_user: logged_user} do
      new_email = "new.email@gmail.com"
      conn = put(conn, user_path(conn, :update, logged_user), user: %{:email => new_email})
      assert redirected_to(conn) == user_path(conn, :show, logged_user)
      updated_user = Repo.get(User, logged_user.id)
      assert updated_user.email == new_email
      assert conn.private.phoenix_flash == %{"info" => "User updated successfully."}
    end

    test "operation update user (another)", %{conn: conn, user: user} do
      new_email = "new.email@gmail.com"
      conn = put(conn, user_path(conn, :update, user), user: %{:email => new_email})
      assert redirected_to(conn) == user_path(conn, :show, user)
      updated_user = Repo.get(User, user.id)
      assert updated_user.email == new_email
      assert conn.private.phoenix_flash == %{"info" => "User updated successfully."}
    end

    test "operation delete user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = delete(conn, user_path(conn, :delete, logged_user))
      assert redirected_to(conn) == user_path(conn, :index)
      assert Repo.get(User, logged_user.id)

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to delete this user!"
             }
    end

    test "operation delete user (another)", %{conn: conn, user: user} do
      conn = delete(conn, user_path(conn, :delete, user))
      assert redirected_to(conn) == user_path(conn, :index)
      refute Repo.get(User, user.id)
      assert conn.private.phoenix_flash == %{"info" => "User deleted successfully."}
    end

    @tag :selected
    test "operation update role (yourself)", %{conn: conn, logged_user: logged_user} do
      new_role = "MANAGER"
      conn = put(conn, user_path(conn, :update, logged_user), user: %{:role => new_role})
      response = html_response(conn, 200)
      assert response =~ "You cannot change role!"
      # assert conn.private.phoenix_flash == %{
      #         "error" => "You have no permissions to delete this user!"
      #       }
    end

    # test "operation update role (another)", %{conn: conn, user: user} do
    #  new_email = "new.email@gmail.com"
    #  conn = put(conn, user_path(conn, :update, user), user: %{:email => new_email})
    #  assert redirected_to(conn) == user_path(conn, :show, user)
    #  updated_user = Repo.get(User, user.id)
    #  assert updated_user.email == new_email
    #  assert conn.private.phoenix_flash == %{"info" => "User updated successfully."}
    # end
  end

  describe " behaviour with restrictions (operations from MANAGER role) : " do
    setup tags do
      {:ok, logged_user} = Factory.insert(:user)
      {:ok, user} = Factory.insert(:admin)
      {:ok, conn: authorize(tags[:conn], logged_user), logged_user: logged_user, user: user}
    end

    test "operation show users table", %{conn: conn, logged_user: logged_user, user: user} do
      conn = get(conn, user_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Users"
      assert response =~ logged_user.email
      refute response =~ user.email
    end

    test "operation new user", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 302)
      assert conn.private.phoenix_flash == %{"error" => "You have no permissions to create user!"}
    end

    test "operation create user", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @valid_attrs)
      user = Repo.get_by(User, %{email: Map.get(@valid_attrs, :email)})
      refute user
      assert redirected_to(conn) == user_path(conn, :index)
      assert conn.private.phoenix_flash == %{"error" => "You have no permissions to create user!"}
    end

    test "operation show user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = get(conn, user_path(conn, :show, logged_user.id))
      response = html_response(conn, 200)
      assert response =~ "User ##{logged_user.id}"
    end

    test "operation show user (another)", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :show, user.id))
      assert redirected_to(conn) == user_path(conn, :index)

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to view this user info!"
             }
    end

    test "operation edit user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = get(conn, user_path(conn, :edit, logged_user.id))
      response = html_response(conn, 200)
      assert response =~ "Edit User:"
    end

    test "operation edit user (another)", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user.id))
      assert redirected_to(conn) == user_path(conn, :index)

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to edit this user!"
             }
    end

    test "operation update user (yourself)", %{conn: conn, logged_user: logged_user} do
      last_name = "New Last Name"
      conn = put(conn, user_path(conn, :update, logged_user), user: %{:last_name => last_name})
      assert redirected_to(conn) == user_path(conn, :show, logged_user)
      updated_user = Repo.get(User, logged_user.id)
      assert updated_user.last_name == last_name
      assert conn.private.phoenix_flash == %{"info" => "User updated successfully."}
    end

    test "operation update user (another)", %{conn: conn, user: user} do
      last_name = "New Last Name"
      conn = put(conn, user_path(conn, :update, user), user: %{:last_name => last_name})
      assert redirected_to(conn) == user_path(conn, :index)
      updated_user = Repo.get(User, user.id)
      refute updated_user.last_name == last_name

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to edit this user!"
             }
    end

    test "operation delete user (yourself)", %{conn: conn, logged_user: logged_user} do
      conn = delete(conn, user_path(conn, :delete, logged_user))
      assert redirected_to(conn) == user_path(conn, :index)
      assert Repo.get(User, logged_user.id)

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to delete this user!"
             }
    end

    test "operation delete user (another)", %{conn: conn, user: user} do
      conn = delete(conn, user_path(conn, :delete, user))
      assert redirected_to(conn) == user_path(conn, :index)
      assert Repo.get(User, user.id)

      assert conn.private.phoenix_flash == %{
               "error" => "You have no permissions to delete this user!"
             }
    end
  end
end
