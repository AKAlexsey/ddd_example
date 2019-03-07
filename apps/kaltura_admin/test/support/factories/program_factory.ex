defmodule KalturaAdmin.ProgramFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Content.Program

  Faker.start()

  def default_attrs,
    do: %{
      name: Faker.Lorem.word(),
      start_datetime: ~N[2010-04-17 14:00:00],
      end_datetime: ~N[2010-04-17 14:00:00],
      epg_id: "p_epg_#{:rand.uniform(10000)}#{:rand.uniform(10000)}"
    }

  def build(attrs) do
    %Program{}
    |> Program.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
    |> (fn
          %{linear_channel_id: _id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: linear_channel_id}} = Factory.insert(:linear_channel)
            Map.put(attrs_map, :linear_channel_id, linear_channel_id)
        end).()
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
