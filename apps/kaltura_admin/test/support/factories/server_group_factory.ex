defmodule KalturaAdmin.ServerGroupFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Servers.ServerGroup

  Faker.start()

  @default_attrs %{
    name: Faker.Lorem.word(),
    description: Faker.Lorem.sentence(),
    status: :active
  }

  def build(attrs) do
    %ServerGroup{}
    |> ServerGroup.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    @default_attrs
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
