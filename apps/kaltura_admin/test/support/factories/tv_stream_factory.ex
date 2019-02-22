defmodule KalturaAdmin.TvStreamFactory do
  alias KalturaAdmin.{Repo, Factory}
  alias KalturaAdmin.Content.TvStream

  Faker.start()

  def default_attrs,
    do: %{
      stream_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}",
      status: "active",
      protocol: "HLS",
      encryption: "NONE",
      linear_channel_id: nil
    }

  def build(attrs) do
    %TvStream{}
    |> TvStream.changeset(prepare_attrs(attrs))
  end

  defp prepare_attrs(attrs) do
    default_attrs()
    |> Map.merge(attrs)
  end

  def insert(attrs) do
    attrs
    |> build()
    |> (fn
          %{linear_channel_id: _id} = attrs_map ->
            attrs_map

          attrs_map ->
            {:ok, %{id: linear_channel_id}} = Factory.insert(:linear_channel)
            Map.put(attrs_map, :linear_channel_id, linear_channel_id)
        end).()
    |> Repo.insert()
  end
end
