defmodule KalturaAdmin.LinearChannelFactory do
  alias KalturaAdmin.Repo
  alias KalturaAdmin.Content.LinearChannel

  Faker.start()

  def default_attrs,
    do: %{
      name: Faker.Lorem.word(),
      code_name: Faker.Lorem.word(),
      description: Faker.Lorem.sentence(),
      dvr_enabled: false,
      epg_id: Faker.Lorem.word(),
      server_group_id: nil
    }

  def build(attrs) do
    %LinearChannel{}
    |> LinearChannel.changeset(prepare_attrs(attrs))
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
end