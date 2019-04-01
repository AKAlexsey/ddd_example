defmodule CtiKaltura.UserFactory do
  @moduledoc false
  alias CtiKaltura.{Repo, User}
  Faker.start()

  @default_admin_attrs %{
    email: "admin@email.ru",
    first_name: "Admin",
    last_name: "Admin",
    password: "qweasd123"
  }

  @default_user_attrs %{
    email: Faker.Internet.email(),
    first_name: Faker.Name.first_name(),
    last_name: Faker.Name.last_name(),
    password: "qweasd123"
  }

  def build_admin(attrs) do
    %User{}
    |> User.changeset(Map.merge(@default_admin_attrs, attrs))
  end

  def build(attrs) do
    %User{}
    |> User.changeset(Map.merge(@default_user_attrs, attrs))
  end

  def insert_admin(attrs) do
    attrs
    |> build_admin()
    |> Repo.insert()
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
