defmodule CtiKaltura.UserControllerTest do
  use CtiKaltura.ConnCase

  alias CtiKaltura.User

  @valid_attrs %{
    email: Faker.Internet.email(),
    first_name: Faker.Name.first_name(),
    last_name: Faker.Name.last_name(),
    password: "qweasd123"
  }
  @invalid_attrs %{}

  setup tags do
    {:ok, user} = Factory.insert(:admin)

    {:ok, conn: authorize(tags[:conn], user), logined_user: user}
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
    assert_error_sent(404, fn ->
      get(conn, user_path(conn, :show, -1))
    end)
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

  test "deletes chosen user", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = delete(conn, user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  test "deletes current user", %{conn: conn, logined_user: logined_user} do
    conn = delete(conn, user_path(conn, :delete, logined_user))
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get(User, logined_user.id)
  end
end
