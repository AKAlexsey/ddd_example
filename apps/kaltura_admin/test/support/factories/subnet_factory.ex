defmodule KalturaAdmin.SubnetFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Area.Subnet

  Faker.start()

  @default_attrs %{
    cidr: "#{Faker.Internet.ip_v4_address()}/30",
    name: Faker.Lorem.word()
  }

  def build(attrs) do
    %Subnet{}
    |> Subnet.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    @default_attrs
    |> (fn
          %{region_id: id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: region_id}} = Factory.insert(:region)
            Map.put(attrs_map, :region_id, region_id)
        end).()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
