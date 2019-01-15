defmodule KalturaAdmin.RegionFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Area.Region

  Faker.start()

  @default_attrs %{
    name: Faker.Lorem.word(),
    description: Faker.Lorem.sentence(),
    status: :active
  }

  def build(attrs) do
    %Region{}
    |> Region.changeset(prepare_attrs(attrs))
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
