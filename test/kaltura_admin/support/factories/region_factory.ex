defmodule CtiKaltura.RegionFactory do
  @moduledoc false
  alias CtiKaltura.Area.Region
  alias CtiKaltura.Repo

  Faker.start()

  def default_attrs,
    do: %{
      name: "#{Faker.Lorem.word()}#{:rand.uniform(10000)}#{:rand.uniform(10000)}",
      description: Faker.Lorem.sentence(),
      status: "ACTIVE"
    }

  def build(attrs) do
    %Region{}
    |> Region.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end

  def insert_and_notify(attrs) do
    attrs
    |> build()
    |> Repo.insert_and_notify()
  end
end
