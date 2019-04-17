defmodule CtiKaltura.TvStreamFactory do
  @moduledoc false
  alias CtiKaltura.Content.TvStream
  alias CtiKaltura.{Factory, Repo}

  Faker.start()

  def default_attrs,
    do: %{
      stream_path: "/#{Faker.Lorem.word()}/#{Faker.Lorem.word()}",
      status: "ACTIVE",
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
    |> (fn
          %{linear_channel_id: id} = attrs_map when not is_nil(id) ->
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

  def insert_and_notify(attrs) do
    attrs
    |> build()
    |> Repo.insert_and_notify()
  end
end
