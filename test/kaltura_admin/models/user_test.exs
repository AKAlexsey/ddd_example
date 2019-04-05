defmodule CtiKaltura.UserTest do
  use CtiKaltura.ModelCase

  alias CtiKaltura.User

  @valid_attrs %{
    email: Faker.Internet.email(),
    first_name: Faker.Name.first_name(),
    last_name: Faker.Name.last_name(),
    password: "qweasd123"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid email #1" do
    changeset = User.changeset(%User{}, %{@valid_attrs | email: "invalid_email"})
    refute changeset.valid?
  end

  test "changeset with invalid email #2" do
    changeset = User.changeset(%User{}, %{@valid_attrs | email: "invalid@email"})
    refute changeset.valid?
  end

  test "changeset with invalid email #3" do
    changeset = User.changeset(%User{}, %{@valid_attrs | email: "invalid.email@ru"})
    refute changeset.valid?
  end

  test "changeset with valid email #1" do
    changeset = User.changeset(%User{}, %{@valid_attrs | email: "a.b@qwe.ru"})
    assert changeset.valid?
  end

  test "changeset with valid email #2" do
    changeset = User.changeset(%User{}, %{@valid_attrs | email: "my.name.o'nil@qwe.ru"})
    assert changeset.valid?
  end

  test "password with 5 chars" do
    changeset = User.changeset(%User{}, %{@valid_attrs | password: "12345"})
    assert !changeset.valid?
  end

  test "password with 6 chars" do
    changeset = User.changeset(%User{}, %{@valid_attrs | password: "123456"})
    assert changeset.valid?
  end

  describe "Update user password" do
    setup do
      {:ok, user} = Factory.insert(:user)
      {:ok, user: user}
    end

    test "password with 5 chars atom keys", %{user: user} do
      changeset = User.changeset(user, %{password: "12345"})
      refute changeset.valid?
    end

    test "password with 6 chars atom keys", %{user: user} do
      changeset = User.changeset(user, %{password: "123456"})
      assert changeset.valid?
    end

    test "password with 5 chars string keys", %{user: user} do
      changeset = User.changeset(user, %{"password" => "12345"})
      refute changeset.valid?
    end

    test "password with 6 chars string keys", %{user: user} do
      changeset = User.changeset(user, %{"password" => "123456"})
      assert changeset.valid?
    end
  end

  test " email is unique" do
    Factory.insert(:user, @valid_attrs)
    changeset = User.changeset(%User{}, @valid_attrs)
    {:error, %{:errors => errors}} = Repo.insert(changeset)

    assert [
             email:
               {"has already been taken",
                [constraint: :unique, constraint_name: "users_email_index"]}
           ] == errors
  end
end
