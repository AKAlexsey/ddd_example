defmodule KalturaServer.DomainModelHandlers.TvStreamHandler do
  @moduledoc false
  @enum_fields [:status, :protocol, :encryption]

  alias DomainModel.TvStream
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  use KalturaServer.DomainModelHandlers.AbstractHandler,
    table: TvStream,
    joined_attributes_and_models: [
      linear_channel_id: "LinearChannel"
    ]

  def before_write(struct) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
  end
end
