defmodule KalturaAdmin.TvStreamFactory do
  alias KalturaAdmin.Repo
  alias KalturaAdmin.Content.TvStream

  Faker.start()

  @default_attrs %{
    code_name: Faker.Lorem.word(),
    description: Faker.Lorem.sentence(),
    dvr_enabled: false,
    epg_id: Faker.Lorem.word(),
    name: Faker.Lorem.word(),
    status: :active,
    protocol: :HLS,
    stream_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}"
  }

  def build(attrs) do
    %TvStream{}
    |> TvStream.changeset(prepare_attrs(attrs))
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
