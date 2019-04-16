defmodule CtiKaltura.SubnetFactory do
  @moduledoc false
  alias CtiKaltura.Area.Subnet
  alias CtiKaltura.{Factory, Repo}

  Faker.start()

  def default_attrs,
    do: %{
      cidr: "#{Faker.Internet.ip_v4_address()}/30",
      name: "#{Faker.Lorem.word()}#{:rand.uniform(10000)}#{:rand.uniform(10000)}"
    }

  def build(attrs) do
    %Subnet{}
    |> Subnet.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{region_id: _id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: region_id}} = Factory.insert(:region)
            Map.put(attrs_map, :region_id, region_id)
        end).()
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
