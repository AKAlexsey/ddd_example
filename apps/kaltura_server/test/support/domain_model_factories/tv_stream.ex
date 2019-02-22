defmodule KalturaServer.DomainModelFactories.TvStream do
  @moduledoc false

  use KalturaServer.DomainModelFactories.AbstractFactory, table: DomainModel.TvStream
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  @enum_fields [:status, :protocol, :encryption]

  def default_attrs do
    %{
      id: next_table_id(),
      stream_path: Faker.Lorem.word(),
      status: "ACTIVE",
      protocol: "HLS",
      encryption: "NONE",
      linear_channel_id: nil
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
    |> put_linear_channel()
    |> normalize_enums()
  end

  defp put_linear_channel(%{linear_channel_id: nil} = write_attrs) do
    %{id: linear_channel_id} = Factory.insert(:linear_channel)

    write_attrs
    |> Map.put(:linear_channel_id, linear_channel_id)
  end

  defp put_linear_channel(write_attrs), do: write_attrs

  defp normalize_enums(write_attrs) do
    @enum_fields
    |> Enum.reduce(write_attrs, fn field, new_attrs ->
      Map.update!(new_attrs, field, &normalize_enum/1)
    end)
  end
end
