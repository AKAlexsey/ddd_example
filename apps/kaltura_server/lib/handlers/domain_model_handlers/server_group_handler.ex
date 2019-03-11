defmodule KalturaServer.DomainModelHandlers.ServerGroupHandler do
  @moduledoc false

  alias DomainModel.ServerGroup
  import KalturaServer.DomainModelContext, only: [normalize_enum: 1]

  @enum_fields [:status]
  use KalturaServer.DomainModelHandlers.AbstractHandler, table: ServerGroup

  def before_write(struct, _raw_attrs) do
    @enum_fields
    |> Enum.reduce(struct, fn field, new_struct ->
      Map.update!(new_struct, field, &normalize_enum/1)
    end)
  end
end
