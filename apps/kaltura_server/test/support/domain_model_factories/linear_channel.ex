defmodule KalturaServer.DomainModelFactories.LinearChannel do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.LinearChannel

  def default_attrs do
    epg_id = "#{Faker.Lorem.word()}#{:rand.uniform(100)}"

    %{
      id: next_table_id(),
      epg_id: epg_id,
      name: Faker.Lorem.word(),
      code_name: "#{epg_id}_name",
      dvr_enabled: true,
      server_group_ids: [],
      program_ids: [],
      tv_stream_ids: []
    }
  end

  def insert(attrs) do
    Amnesia.transaction(fn ->
      DomainModel.LinearChannel.__struct__()
      |> struct(prepare_attrs(attrs))
      |> DomainModel.LinearChannel.write()
    end)
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end
end
