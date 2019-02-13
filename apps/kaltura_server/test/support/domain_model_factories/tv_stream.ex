defmodule KalturaServer.DomainModelFactories.TvStream do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.TvStream

  def default_attrs do
    epg_id = "#{Faker.Lorem.word()}#{:rand.uniform(100)}"

    %{
      id: next_table_id(),
      epg_id: epg_id,
      stream_path: Faker.Lorem.word(),
      status: :active,
      protocol: :HLS,
      name: Faker.Lorem.word(),
      code_name: "#{epg_id}_name",
      server_group_ids: [],
      program_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.TvStream.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.TvStream.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end
end
