defmodule KalturaAdmin.ProgramFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Content.Program

  Faker.start()

  @default_attrs %{
    name: Faker.Lorem.word(),
    start_datetime: ~N[2010-04-17 14:00:00],
    end_datetime: ~N[2010-04-17 14:00:00],
    epg_id: "program#{:rand.uniform(10)}"
  }

  def build(attrs) do
    %Program{}
    |> Program.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    @default_attrs
    |> (fn
          %{tv_stream_id: id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: tv_stream_id}} = Factory.insert(:tv_stream)
            Map.put(attrs_map, :tv_stream_id, tv_stream_id)
        end).()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> Repo.insert()
  end
end
