defmodule KalturaAdmin.SubnetFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Area.Subnet

  Faker.start()

  def default_attrs,
    do: %{
      cidr: "#{Faker.Internet.ip_v4_address()}/30",
      name: Faker.Lorem.word()
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
end
