defmodule KalturaServer.DomainModelHandlers.RegionHandler do
  @moduledoc false

  require Amnesia
  require Amnesia.Helper
  alias DomainModel.Region
  import KalturaServer.Utils, only: [differences_between_arrays: 2]

  @joined_attributes_and_models [
    subnet_ids: "Subnet",
    server_group_ids: "ServerGroup"
  ]

  @kaltura_server_public_api Application.get_env(:kaltura_admin, :public_api)[:module]

  def handle(action, attrs) when action in [:insert, :update, :refresh] do
    Amnesia.transaction do
      refresh_linked_tables_if_necessary(attrs)
      write_to_table(attrs)
    end

    :ok
  end

  def handle(:refresh_by_request, attrs) do
    Amnesia.transaction do
      write_to_table(attrs)
    end

    :ok
  end

  def handle(:delete, %{id: id}) do
    Amnesia.transaction do
      Region.delete(id)
    end
  end

  defp refresh_linked_tables_if_necessary(%{id: id} = attrs) do
    case Region.read(id) do
      nil ->
        :ok

      record ->
        @joined_attributes_and_models
        |> Enum.each(fn {attribute, model_name} ->
          current_value = Map.get(record, attribute)
          new_value = Map.get(attrs, attribute)

          case differences_between_arrays(current_value, new_value) do
            [] ->
              :ok

            ids ->
              ids
              |> Enum.each(fn id ->
                @kaltura_server_public_api.cache_model_record(model_name, id)
              end)
          end
        end)
    end
  end

  defp write_to_table(attrs) do
    %Region{}
    |> struct(attrs)
    |> Region.write()
  end
end
